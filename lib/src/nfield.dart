import 'package:flutter/material.dart';

import 'nvar.dart';

/// [NField] is a widget that listens to an [NVar] and rebuilds only when the value actually changes
class NField<T> extends StatelessWidget {
  /// [data] is the [NVar] to listen to
  final NVar<T> data;

  /// [builder] is the widget builder
  final Widget Function(T data) builder;

  /// Optional function to control when widget should rebuild.
  /// If not provided, uses == comparison by default.
  /// Return true to rebuild, false to skip.
  final bool Function(T previous, T current)? shouldRebuild;

  /// [NField] is a widget that listens to an [NVar] and rebuilds only when the value actually changes
  const NField({required this.data, required this.builder, this.shouldRebuild, super.key});

  @override
  Widget build(BuildContext context) => builder(data.value);

  @override
  StatelessElement createElement() => _NFieldElement<T>(this);
}

class _NFieldElement<T> extends StatelessElement {
  T? _previousValue;

  _NFieldElement(NField<T> super.widget);

  NField<T> get _widget => widget as NField<T>;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    if (_widget.shouldRebuild != null) _previousValue = _widget.data.value;
    _widget.data.addListener(_listener);
  }

  @override
  void update(StatelessWidget newWidget) {
    final oldWidget = _widget;
    super.update(newWidget);

    if (oldWidget.data != _widget.data) {
      oldWidget.data.removeListener(_listener);
      if (_widget.shouldRebuild != null) _previousValue = _widget.data.value;
      _widget.data.addListener(_listener);
    }
  }

  @override
  void unmount() {
    _widget.data.removeListener(_listener);
    super.unmount();
  }

  /// listener for controller that update widget when update was call from controller
  void _listener(T newValue) {
    if (!mounted) return;

    assert(
      _widget.shouldRebuild == null || _previousValue != null,
      'Internal error: _previousValue not initialized. '
      'This usually happens during hot reload. '
      'Please restart the app (not hot reload).',
    );

    final shouldUpdate = _widget.shouldRebuild?.call(_previousValue as T, newValue) ?? true;

    if (!shouldUpdate) return;

    if (_widget.shouldRebuild != null) _previousValue = newValue;
    markNeedsBuild();
  }
}
