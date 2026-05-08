extension StringCasingExt on String {
  /// Capitalizes the first character, leaves the rest untouched.
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Title-cases hyphen- or space-separated words: `mr-mime` → `Mr Mime`.
  String toTitleCase() {
    if (isEmpty) return this;
    return split(RegExp(r'[\s\-]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w.capitalize())
        .join(' ');
  }
}
