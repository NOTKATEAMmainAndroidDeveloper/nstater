import 'package:flutter/foundation.dart';

abstract class NController<T> {
  final List<void Function()> _listeners = [];

  void addListener(void Function() listener) {
    if (!_listeners.contains(listener)) _listeners.add(listener);
  }

  void removeListener(void Function() listener) => _listeners.remove(listener);

  @protected
  void update() {
    final snapshot = List<void Function()>.from(_listeners);
    for (final l in snapshot) {
      try {
        l();
      } catch (_) {}
    }
  }

  void setAndUpdate(void Function() mutate) {
    mutate();
    update();
  }

  @mustCallSuper
  void onInit() {}

  @mustCallSuper
  void onReady() {}

  @mustCallSuper
  void unmount() {}

  @mustCallSuper
  void beforeMount() {}
}
