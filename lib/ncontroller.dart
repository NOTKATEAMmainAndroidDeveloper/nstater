import 'package:flutter/foundation.dart';

/// Base controller
abstract class NController<T> {
  final List<void Function()> _listeners = [];

  /// Subscribe to changes with [listener]
  void addListener(void Function() listener) {
    if (!_listeners.contains(listener)) _listeners.add(listener);
  }

  /// Unsubscribe from changes with [listener]
  void removeListener(void Function() listener) => _listeners.remove(listener);

  /// Update all listeners
  @protected
  void update() {
    final snapshot = List<void Function()>.from(_listeners);
    for (final l in snapshot) {
      try {
        l();
      } catch (_) {}
    }
  }

  /// First start [matate] and then update listeners
  void setAndUpdate(void Function() mutate) {
    mutate();
    update();
  }

  /// Call on widget start render
  @mustCallSuper
  void onInit() {}

  /// Call when widget is ready
  @mustCallSuper
  void onReady() {}

  /// Call on widget unmount
  @mustCallSuper
  void unmount() {}

  /// Call before widget mount, its called before [onInit]
  @mustCallSuper
  void beforeMount() {}
}
