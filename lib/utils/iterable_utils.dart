extension IterableHandling<K> on Iterable<K> {
  List<T> mapList<T>(
    T Function(K e) toElement, {
    bool growable = true,
  }) {
    return map(toElement).toList(growable: growable);
  }

  List<K> whereList(
    bool Function(K e) test, {
    bool growable = true,
  }) {
    return where(test).toList(growable: growable);
  }
}
