class CacheManager {
  static const Duration cacheDuration = Duration(minutes: 10);
  DateTime? _lastFetchTime;

  CacheManager({DateTime? lastFetchTime}) : _lastFetchTime = lastFetchTime;

  bool shouldRefresh() {
    return _lastFetchTime == null ||
        DateTime.now().difference(_lastFetchTime!) > cacheDuration;
  }

  void updateLastFetchTime() {
    _lastFetchTime = DateTime.now();
  }

  DateTime? get lastFetchTime => _lastFetchTime;
}
