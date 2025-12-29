extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String removeSuffix(String suffix) {
    if (endsWith(suffix)) {
      return substring(0, length - suffix.length);
    }
    return this;
  }

  String? getStringOrNull() => isEmpty ? null : this;
}

extension ListExtension<T> on List<T> {
  T? getOrNull(int index) => index < length ? this[index] : null;
}
