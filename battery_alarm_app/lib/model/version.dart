class Version {
  Version({
    required this.major,
    required this.minor,
    required this.patch,
    required this.build,
  });

  final int major;
  final int minor;
  final int patch;
  final int build;

  bool isBetterThan(Version other) => compare(other) > 0;

  int compare(Version other) {
    if (major < other.major) return -1;
    if (major > other.major) return 1;
    if (minor < other.minor) return -1;
    if (minor > other.minor) return 1;
    if (patch < other.patch) return -1;
    if (patch > other.patch) return 1;
    if (build < other.build) return -1;
    if (build > other.build) return 1;
    return 0;
  }

  String toString() {
    final parts = [major,minor,patch].map((val) => val.toString());
    if (build == 0) return parts.join('.');
    return '${parts.join('.')}-build.${build.toString()}';
  }

  static Version? parse(String value) {
    int major = 0;
    int minor = 0;
    int patch = 0;
    int build = 0;

    final parts = value.replaceAll('-', '.').split('.');
    if (parts.isNotEmpty) {
      final value = int.tryParse(parts[0]);
      if (value == null) return null;
      major = value;
    }

    if (parts.length >= 2) {
      final value = int.tryParse(parts[1]);
      if (value == null) return null;
      minor = value;
    }

    if (parts.length >= 3) {
      final value = int.tryParse(parts[2]);
      if (value == null) return null;
      patch = value;
    }

    if (parts.length >= 5 && parts[3] == 'build') {
      final value = int.tryParse(parts[4]);
      if (value == null) return null;
      build = value;
    }

    return Version(
      major: major,
      minor: minor,
      patch: patch,
      build: build,
    );
  }
}
