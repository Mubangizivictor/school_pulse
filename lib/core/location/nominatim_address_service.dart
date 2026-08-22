import 'dart:convert';

import 'package:http/http.dart' as http;

class AddressSuggestion {
  final String displayName;
  final String? region;
  final String? county;
  final String? country;

  const AddressSuggestion({
    required this.displayName,
    this.region,
    this.county,
    this.country,
  });
}

/// Free-tier address lookup via OpenStreetMap's Nominatim public API.
/// No API key. Nominatim's usage policy caps this at ~1 request/second, so
/// callers must debounce keystrokes rather than search on every character.
class NominatimAddressService {
  static const _baseUrl = 'https://nominatim.openstreetmap.org/search';

  Future<List<AddressSuggestion>> search(String query) async {
    if (query.trim().length < 3) return const [];
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'q': query.trim(),
        'format': 'jsonv2',
        'addressdetails': '1',
        'limit': '5',
      },
    );
    try {
      final response = await http.get(
        uri,
        // Nominatim's usage policy requires an identifying User-Agent.
        headers: const {'User-Agent': 'SchoolPulseApp/1.0'},
      );
      if (response.statusCode != 200) return const [];
      final results = jsonDecode(response.body) as List;
      return results.map((r) {
        final address = r['address'] as Map<String, dynamic>? ?? {};
        return AddressSuggestion(
          displayName: r['display_name'] as String? ?? '',
          region: address['state'] as String? ?? address['region'] as String?,
          county:
              address['county'] as String? ?? address['district'] as String?,
          country: address['country'] as String?,
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }
}
