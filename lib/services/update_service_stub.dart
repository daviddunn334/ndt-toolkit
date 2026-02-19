class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  Stream<String> get updateAvailableStream => const Stream.empty();
  String? get newVersion => null;

  Future<void> initialize() async {}
  Future<void> checkForUpdate() async {}
  Future<void> applyUpdate({bool immediate = false}) async {}
  Future<String?> getCurrentVersion() async => null;
  Future<void> clearCache() async {}
  void dispose() {}
}