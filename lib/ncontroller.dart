abstract class NController<T> {
  final List<Function()> _listeners = [];

  void addListener(Function() listener) => _listeners.contains(listener) ? null : _listeners.add(listener);

  void removeListener(Function() listener) => _listeners.remove(listener);

  void unmount() {}

  void update() {
    for (var listener in _listeners) {
      listener();
    }
  }

  NController();
}
