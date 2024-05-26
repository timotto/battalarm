class OtaArtifact {
  final int size;
  final List<int> sha256;
  final List<int> data;

  OtaArtifact({
    required this.size,
    required this.sha256,
    required this.data,
  });
}
