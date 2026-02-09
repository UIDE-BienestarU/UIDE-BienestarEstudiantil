class CacheBox<T> {
  T? data;
  DateTime? fetchedAt;

  bool get hasData => data != null;

  bool isFresh(Duration ttl) {
    if (fetchedAt == null) return false;
    return DateTime.now().difference(fetchedAt!) < ttl;
  }

  void set(T value) {
    data = value;
    fetchedAt = DateTime.now();
  }

  void clear() {
    data = null;
    fetchedAt = null;
  }
}
