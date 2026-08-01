import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../domain/entities/notification_preferences.dart';
import '../domain/policies/notification_delivery_policy.dart';

/// On-device cache for notification images.
///
/// Exists for three reasons the spec calls out:
///  - a cached thumbnail lets the notification centre render offline,
///  - re-downloading the same banner on every list build wastes the user's
///    data allowance, which matters on the mobile-data-heavy deployment,
///  - Android and iOS rich notifications need a *local file path*; they cannot
///    render a remote URL, so a push with an image must have it on disk first.
///
/// Files are keyed by a hash of the URL, so the same image referenced by two
/// notifications is stored once.
class NotificationImageCache {
  /// Connectivity check used to enforce the wifi-only download policy.
  final Future<bool> Function() isOnWifi;

  /// Injected so tests can supply a fake without hitting the network.
  final http.Client client;

  /// Cap on a single download. A malformed or hostile URL pointing at a huge
  /// file would otherwise fill the device.
  static const maxBytes = 5 * 1024 * 1024;

  /// Entries older than this are eligible for eviction.
  static const maxAge = Duration(days: 30);

  Directory? _directory;

  NotificationImageCache({
    required this.isOnWifi,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<Directory> _cacheDirectory() async {
    final existing = _directory;
    if (existing != null) return existing;

    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/notification_images');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _directory = dir;
    return dir;
  }

  /// Deterministic filename for [url]. Hashed rather than derived from the URL
  /// text so query strings and signed-URL tokens do not produce a new file for
  /// what is the same image, and so nothing user-supplied reaches the path.
  String _fileNameFor(String url) {
    final digest = sha1.convert(utf8.encode(url)).toString();
    return '$digest.img';
  }

  /// Returns the local path for [url] if it is already cached, without
  /// downloading. Safe to call on any connection, including none.
  Future<String?> cachedPath(String url) async {
    if (url.isEmpty) return null;
    try {
      final dir = await _cacheDirectory();
      final file = File('${dir.path}/${_fileNameFor(url)}');
      return await file.exists() ? file.path : null;
    } catch (e) {
      _log('cache lookup failed', e);
      return null;
    }
  }

  /// Resolves [url] to a local file, downloading it when policy permits.
  ///
  /// Returns null rather than throwing when the image cannot be obtained -
  /// a notification must stay readable without its image, so every caller
  /// treats null as "render the placeholder".
  ///
  /// [isThumbnail] bypasses the wifi-only rule: thumbnails are small and the
  /// list looks broken without them, whereas a full banner is what Data Saver
  /// is actually protecting the user from.
  Future<String?> resolve(
    String url, {
    ImageDownloadPolicy policy = ImageDownloadPolicy.wifiOnly,
    bool isThumbnail = false,
  }) async {
    if (url.isEmpty) return null;

    final existing = await cachedPath(url);
    if (existing != null) return existing;

    if (!isThumbnail) {
      final onWifi = await _safeIsOnWifi();
      final permitted = NotificationDeliveryPolicy.mayDownloadFullImage(
        policy: policy,
        isOnWifi: onWifi,
      );
      if (!permitted) return null;
    } else if (policy == ImageDownloadPolicy.never) {
      // "Never" means never, including thumbnails.
      return null;
    }

    return _download(url);
  }

  Future<bool> _safeIsOnWifi() async {
    try {
      return await isOnWifi();
    } catch (e) {
      // Unknown connection: assume metered, which is the conservative choice
      // for a user on a data bundle.
      _log('connectivity check failed, assuming metered', e);
      return false;
    }
  }

  Future<String?> _download(String url) async {
    try {
      final uri = Uri.tryParse(url);
      // Only http(s). A file:// or data: URL here would be a way to read
      // something off the device into a notification.
      if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
        return null;
      }

      final response = await client
          .get(uri)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) return null;
      if (response.bodyBytes.length > maxBytes) {
        _log('image rejected', 'exceeds $maxBytes bytes');
        return null;
      }
      if (!_looksLikeImage(response)) {
        _log('image rejected', 'unexpected content type');
        return null;
      }

      final dir = await _cacheDirectory();
      final file = File('${dir.path}/${_fileNameFor(url)}');

      // Written to a temporary name then renamed, so a download interrupted
      // part-way cannot leave a truncated file that later reads as "cached".
      final temp = File('${file.path}.part');
      await temp.writeAsBytes(response.bodyBytes, flush: true);
      await temp.rename(file.path);

      return file.path;
    } catch (e) {
      _log('image download failed', e);
      return null;
    }
  }

  /// Guards against a URL that returns HTML (a login page, an error page)
  /// being cached and then handed to the OS as a notification image.
  bool _looksLikeImage(http.Response response) {
    final contentType = response.headers['content-type'];
    if (contentType != null) {
      return contentType.toLowerCase().startsWith('image/');
    }
    // No content-type: fall back to sniffing the common magic numbers.
    final bytes = response.bodyBytes;
    if (bytes.length < 4) return false;
    // JPEG, PNG, GIF, WEBP (RIFF).
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) return true;
    if (bytes[0] == 0x89 && bytes[1] == 0x50) return true;
    if (bytes[0] == 0x47 && bytes[1] == 0x49) return true;
    if (bytes[0] == 0x52 && bytes[1] == 0x49) return true;
    return false;
  }

  /// Deletes cached images older than [maxAge].
  ///
  /// Called on app start rather than on a timer - the cache grows slowly, and
  /// a background timer would keep the isolate alive for no benefit.
  Future<int> evictStale({DateTime? now}) async {
    try {
      final dir = await _cacheDirectory();
      if (!await dir.exists()) return 0;

      final cutoff = (now ?? DateTime.now()).subtract(maxAge);
      var removed = 0;

      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        try {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoff)) {
            await entity.delete();
            removed++;
          }
        } catch (_) {
          // A file vanishing mid-sweep is fine; skip it.
        }
      }
      return removed;
    } catch (e) {
      _log('eviction failed', e);
      return 0;
    }
  }

  /// Removes everything. Used on sign-out so a shared device does not retain
  /// one user's notification imagery for the next.
  Future<void> clear() async {
    try {
      final dir = await _cacheDirectory();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      _directory = null;
    } catch (e) {
      _log('cache clear failed', e);
    }
  }

  static void _log(String message, Object detail) {
    if (kDebugMode) debugPrint('[notifications] $message: $detail');
  }
}
