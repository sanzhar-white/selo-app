class CacheManager {
  CacheManager({DateTime? lastFetchTime}) : _lastFetchTime = lastFetchTime;
  static const Duration cacheDuration = Duration(minutes: 1);
  DateTime? _lastFetchTime;

  bool shouldRefresh() {
    return _lastFetchTime == null ||
        DateTime.now().difference(_lastFetchTime!) > cacheDuration;
  }

  void updateLastFetchTime() {
    _lastFetchTime = DateTime.now();
  }

  DateTime? get lastFetchTime => _lastFetchTime;
}
