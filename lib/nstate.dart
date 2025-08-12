import 'package:flutter/material.dart';

import 'ncontroller.dart';

class NState<T> extends StatelessWidget {
  final T Function() create;
  final Widget Function(T controller) builder;
  final NController _controller;

  NController get controller => _controller;

  NState({super.key, required this.create, required this.builder}) : _controller = create() as NController;

  @override
  Widget build(BuildContext context) => builder(_controller as T);

  @override
  StatelessElement createElement() => _NStateElement(this);
}

class _NStateElement<T> extends StatelessElement {
  _NStateElement(NState super.widget);

  NState get _widget => widget as NState;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _widget.controller.addListener(_listener);
  }

  @override
  void update(StatelessWidget newWidget) {
    final oldWidget = _widget;
    super.update(newWidget);

    if (oldWidget.controller != _widget.controller) {
      oldWidget.controller.removeListener(_listener);
      _widget.controller.addListener(_listener);
    }
  }

  @override
  void unmount() {
    _widget.controller.removeListener(_listener);
    _widget.controller.unmount();
    super.unmount();
  }

  void _listener() => markNeedsBuild();
}
