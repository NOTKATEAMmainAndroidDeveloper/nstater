import 'package:flutter/foundation.dart';

/// Base controller
abstract class NController<T> {
  final List<void Function()> _listeners = [];
  bool _disposed = false;

  /// Subscribe to changes with [listener]
  void addListener(void Function() listener) {
    if (!_listeners.contains(listener)) _listeners.add(listener);
  }

  /// Unsubscribe from changes with [listener]
  void removeListener(void Function() listener) => _listeners.remove(listener);

  /// Update all listeners
  @protected
  void update() {
    if (_disposed){
      _disposedWarning('Can\'t update disposed controller');
      return;
    }

    final snapshot = List<void Function()>.from(_listeners);
    for (final l in snapshot) {
      try {
        l();
      } catch (ex, stack) {
        debugPrint('NController error: $ex\n$stack');
      }
    }
  }

  /// First start [mutate] and then update listeners
  void setAndUpdate(void Function() mutate) {
    if (_disposed){
      _disposedWarning('Can\'t update disposed controller');
      return;
    }

    mutate();
    update();
  }

  /// Call on widget start render
  @mustCallSuper
  void onInit() {}

  /// Call when widget is ready
  @mustCallSuper
  void onReady() {}

  /// Call on widget dispose
  @mustCallSuper
  void dispose() {
    if (_disposed){
      _disposedWarning('NController already disposed');
      return;
    }

    _disposed = true;
    _listeners.clear();
  }

  /// Call before widget mount, its called before [onInit]
  @mustCallSuper
  void beforeMount() {}

  /// Internal method to print warning when try to call disposed controller
  void _disposedWarning(String message) =>
      debugPrint('❌ Try to call disposed NController with type: ${runtimeType.toString()}\n$message');
}
