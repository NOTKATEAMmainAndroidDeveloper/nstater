class NVar<T> {
  final List<Function(T newValue)> _listeners = [];
  T _value;

  T get value => _value;

  set value(T newValue) {
    if (identical(_value, newValue)) return;

    _value = newValue;
    for (final l in _listeners) {
      l(newValue);
    }
  }

  addListener(Function(T newValue) listener) => _listeners.contains(listener) ? null : _listeners.add(listener);

  removeListener(Function(T newValue) listener) => _listeners.remove(listener);

  NVar(T initialValue) : _value = initialValue;
}
