import 'package:shared_preferences/shared_preferences.dart';

/// Device-local chat settings, shared by the Chat Settings screen (which
/// writes them) and the inbox and chat screens (which have to honour them).
///
/// Deliberately per-device rather than synced to the account: font size and
/// whether Enter sends are properties of the phone you are holding, not of
/// who you are.
class ChatPreferences {
  static const String enterIsSendKey = 'messages.enter_is_send';
  static const String mediaVisibilityKey = 'messages.media_visibility';
  static const String keepArchivedKey = 'messages.keep_archived';
  static const String fontSizeKey = 'messages.font_size';

  static const List<String> fontSizes = ['Small', 'Medium', 'Large'];

  final bool enterIsSend;
  final bool mediaVisibility;

  /// When false, a chat pops back out of the archive as soon as a new
  /// message arrives in it.
  final bool keepArchived;

  final String fontSize;

  const ChatPreferences({
    this.enterIsSend = false,
    this.mediaVisibility = true,
    this.keepArchived = true,
    this.fontSize = 'Medium',
  });

  /// Multiplier applied to message text, so "Font size" actually changes
  /// something rather than only remembering itself.
  double get textScale {
    switch (fontSize) {
      case 'Small':
        return 0.9;
      case 'Large':
        return 1.2;
      default:
        return 1.0;
    }
  }

  static Future<ChatPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ChatPreferences(
      enterIsSend: prefs.getBool(enterIsSendKey) ?? false,
      mediaVisibility: prefs.getBool(mediaVisibilityKey) ?? true,
      keepArchived: prefs.getBool(keepArchivedKey) ?? true,
      fontSize: prefs.getString(fontSizeKey) ?? 'Medium',
    );
  }
}
