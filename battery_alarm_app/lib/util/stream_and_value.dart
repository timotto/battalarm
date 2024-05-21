class StreamAndValue<T> {
  StreamAndValue({
    required this.stream,
    required this.value,
  });

  final Stream<T> stream;
  final T value;
}
