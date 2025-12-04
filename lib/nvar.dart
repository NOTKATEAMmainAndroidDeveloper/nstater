/// [NVar] is reactive value with subscribe / unsubscribe
class NVar<T> {
  final List<Function(T newValue)> _listeners = [];
  T _value;

  /// [NVar] is reactive value with subscribe / unsubscribe
  NVar(T initialValue) : _value = initialValue;

  /// Get current value
  T get value => _value;

  set value(T newValue) {
    if (identical(_value, newValue)) return;

    _value = newValue;
    for (final l in _listeners) {
      l(newValue);
    }
  }

  /// Add new [listener] to [NVar]
  void addListener(Function(T newValue) listener) => _listeners.contains(listener) ? null : _listeners.add(listener);

  /// Remove [listener] from [NVar]
  void removeListener(Function(T newValue) listener) => _listeners.remove(listener);
}
