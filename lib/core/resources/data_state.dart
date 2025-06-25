abstract class DataState<T> {

  const DataState({this.data, this.error, this.stackTrace});
  final T? data;
  final Exception? error;
  final StackTrace? stackTrace;
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(Exception error, StackTrace stackTrace)
    : super(error: error, stackTrace: stackTrace);
}

class DataLoading<T> extends DataState<T> {
  const DataLoading();
}
