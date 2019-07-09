import 'package:rxdart/rxdart.dart';

/// perform a computation on a stream with debounce, ensuring only the results of the most latest
/// input are emitted
Observable<T> computeAndDropOldResults<S, T>(Observable<S> source, Future<T> fn(S s)) {
  return source
      .distinct()
      .debounceTime(Duration(milliseconds: 250))
      // pair the result with the source used to compute it
      .asyncMap((s) => fn(s).then((t) => MapEntry(s, t)))
      // pair with the latest source
      .withLatestFrom(source, (e, ns) => MapEntry(e, ns))
      // filter out results where the source doesn't match the latest source
      .where((ne) => ne.key.key == ne.value)
      // extract the result
      .map((ne) => ne.key.value);
}

/// like computeAndDropOldResults but will emit null immediately when a new input is available (before debounce)
Observable<T> computeAndDropOldResultsInvalidate<S, T>(Observable<S> source, Future<T> fn(S s)) {
  final distinctSource = source.distinct();
  return Observable.merge([
    distinctSource.mapTo(null),
    computeAndDropOldResults(source, fn),
  ]);
}
