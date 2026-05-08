abstract interface class HealthSyncService {
  Future<bool> connect();
  Future<void> syncWorkouts();
  Future<void> syncBodyMetrics();
}

class HealthSyncServiceStub implements HealthSyncService {
  @override
  Future<bool> connect() async => false;

  @override
  Future<void> syncBodyMetrics() async {}

  @override
  Future<void> syncWorkouts() async {}
}
