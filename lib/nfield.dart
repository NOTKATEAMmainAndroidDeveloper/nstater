import 'package:flutter/material.dart';

import 'nvar.dart';

class NField<T> extends StatelessWidget {
  final NVar<T> data;
  final Widget Function(T data) builder;

  const NField({super.key, required this.data, required this.builder});

  @override
  Widget build(BuildContext context) => builder(data.value);

  @override
  StatelessElement createElement() => _NFieldElement<T>(this);
}

class _NFieldElement<T> extends StatelessElement {
  _NFieldElement(NField<T> super.widget);

  NField<T> get _widget => widget as NField<T>;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _widget.data.addListener(_listener);
  }

  @override
  void update(StatelessWidget newWidget) {
    final oldWidget = _widget;
    super.update(newWidget);

    if (oldWidget.data != _widget.data) {
      oldWidget.data.removeListener(_listener);
      _widget.data.addListener(_listener);
    }
  }

  @override
  void unmount() {
    _widget.data.removeListener(_listener);
    super.unmount();
  }

  void _listener(T _) => markNeedsBuild();
}
