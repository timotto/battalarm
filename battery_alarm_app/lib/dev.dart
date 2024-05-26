class DeveloperService {
  static final DeveloperService _sharedInstance = DeveloperService._();

  factory DeveloperService() => _sharedInstance;

  DeveloperService._();

  bool isDeveloper = false;
}
