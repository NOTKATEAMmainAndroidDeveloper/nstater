import 'dart:async';

import 'package:flutter/material.dart';

import 'ncontroller.dart';

/// NState — widget that creates a controller and manages its lifecycle
class NState<T> extends StatelessWidget {
  /// Method for creating a controller
  final T Function() create;

  /// Widget builder that pass a [controller]
  final Widget Function(T controller) builder;

  /// NState — widget that creates a controller and manages its lifecycle
  const NState({required this.create, required this.builder, super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  @override
  StatelessElement createElement() => _NStateElement<T>(this);
}

class _NStateElement<T> extends StatelessElement {
  _NStateElement(NState super.widget);

  NState<T> get _widget => widget as NState<T>;

  late final NController _controller = _widget.create() as NController;

  @override
  void mount(Element? parent, Object? newSlot) {
    _controller.beforeMount();
    super.mount(parent, newSlot);
    _controller.onInit();
    _controller.addListener(_listener);

    scheduleMicrotask(() {
      if (mounted) _controller.onReady();
    });
  }

  @override
  Widget build() => _widget.builder(_controller as T);

  @override
  void unmount() {
    _controller.removeListener(_listener);
    _controller.dispose();
    super.unmount();
  }

  /// listener for controller that update widget when update was call from controller
  void _listener() {
    if (mounted) markNeedsBuild();
  }
}
