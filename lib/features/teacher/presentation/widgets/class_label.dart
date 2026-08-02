/// A compact token for a class tile: "Primary 3" becomes P3, "Grade 10A"
/// becomes G10A, "S1" stays S1.
///
/// Taking the first word instead - which the mocked-up "Grade 10A" happened
/// to make look reasonable - renders every Primary class in a primary school
/// as an identical "Primary" tile, so sibling classes become
/// indistinguishable in the list.
String classInitials(String className, {String fallback = ''}) {
  if (className.trim().isEmpty) return fallback;

  final words = className.trim().split(RegExp(r'\s+'));
  if (words.length == 1) {
    final single = words.first;
    return single.length <= 4 ? single : single.substring(0, 4);
  }

  // Leading letter of each word, plus any number or stream token trailing it.
  final letters = words
      .where((w) => RegExp(r'^[A-Za-z]').hasMatch(w))
      .map((w) => w[0].toUpperCase())
      .join();
  final tail = words.where((w) => RegExp(r'\d').hasMatch(w)).join();

  final token = '$letters$tail';
  if (token.isEmpty) return className;
  return token.length <= 5 ? token : token.substring(0, 5);
}
