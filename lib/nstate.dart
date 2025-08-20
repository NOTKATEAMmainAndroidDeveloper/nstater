import 'dart:async';

import 'package:flutter/material.dart';

import 'ncontroller.dart';

class NState<T> extends StatelessWidget {
  final T Function() create;
  final Widget Function(T controller) builder;

  const NState({super.key, required this.create, required this.builder});

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
  Widget build() {
    return _widget.builder(_controller as T);
  }

  @override
  void update(StatelessWidget newWidget) {
    super.update(newWidget);
  }

  @override
  void unmount() {
    _controller.removeListener(_listener);
    _controller.unmount();
    super.unmount();
  }

  void _listener() {
    if (mounted) {
      markNeedsBuild();
    }
  }
}
