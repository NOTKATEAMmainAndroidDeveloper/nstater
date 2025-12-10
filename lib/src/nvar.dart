import 'package:flutter/foundation.dart';

/// [NVar] is reactive value with subscribe / unsubscribe
class NVar<T> {
  /// Custom equality function used to notify listeners when result is false
  /// if null uses == operator
  /// other use result of [isEqual] function that give to compare [oldValue] and [newValue]
  ///
  /// Be cautious to use with NField because it has shouldRebuild method
  final bool Function(T oldValue, T newValue)? isEqual;

  final List<void Function(T newValue)> _listeners = [];
  T _value;

  /// [NVar] is reactive value with subscribe / unsubscribe
  NVar(T initialValue, {this.isEqual}) : _value = initialValue;

  /// Get current value
  T get value => _value;

  set value(T newValue) {
    if (isEqual?.call(_value, newValue) ?? (_value == newValue)) return;

    _value = newValue;
    final snapshot = List<void Function(T newValue)>.from(_listeners);
    for (final l in snapshot) {
      try {
        l(newValue);
      } catch (ex, stack) {
        debugPrint('❌ NVar listener error: $ex\n$stack');
      }
    }
  }

  /// Add new [listener] to [NVar]
  void addListener(void Function(T newValue) listener) =>
      _listeners.contains(listener) ? null : _listeners.add(listener);

  /// Remove [listener] from [NVar]
  void removeListener(void Function(T newValue) listener) => _listeners.remove(listener);

  /// Clear all listeners
  void dispose() => _listeners.clear();
}
