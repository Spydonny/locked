class AppLocalCache {
  const AppLocalCache();

  Future<void> enqueueMutation(String key, Map<String, dynamic> payload) async {}

  Future<List<Map<String, dynamic>>> pendingMutations() async => const [];
}
