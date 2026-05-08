import 'dart:async';

class RealtimeSyncService {
  final StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get events => _controller.stream;

  void push(Map<String, dynamic> event) {
    _controller.add(event);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
