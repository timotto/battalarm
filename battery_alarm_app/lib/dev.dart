class DeveloperService {
  static final DeveloperService _sharedInstance = DeveloperService._();

  factory DeveloperService() => _sharedInstance;

  DeveloperService._();

  bool isDeveloper = false;

  static String formatVersionString(String value) =>
      DeveloperService().isDeveloper ? value : _stripVersionDetails(value);

  static String _stripVersionDetails(String value) =>
      value.length > 5 ? value.split('-')[0] : value;
}
