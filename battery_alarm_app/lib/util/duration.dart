String formatDuration(Duration? duration) {
  if (duration == null) return '-';

  final List<String> parts = [];

  if (duration.compareTo(const Duration(hours: 1)) >= 0) {
    parts.add('${duration.inHours}h');
    duration = duration - Duration(hours: duration.inHours);
  }

  if (duration.compareTo(const Duration(minutes: 1)) >= 0) {
    parts.add('${duration.inMinutes}m');
    duration = duration - Duration(minutes: duration.inMinutes);
  }

  if (duration.compareTo(const Duration(seconds: 1)) >= 0) {
    parts.add('${duration.inSeconds}s');
    duration = duration - Duration(minutes: duration.inSeconds);
  }

  return parts.join(' ');
}