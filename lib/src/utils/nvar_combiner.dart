import 'package:nstater/nstater.dart' show NVar;

/// Universal combiner for any count NVar
class NVarCombiner<R> extends NVar<R> {
  final List<NVar> _sources;
  final R Function() _combiner;

  /// Universal combiner for any count NVar
  NVarCombiner(List<NVar> sources, R Function() combiner)
    : _sources = sources,
      _combiner = combiner,
      super(combiner()) {
    for (final source in _sources) {
      source.addListener(_onUpdate);
    }
  }

  void _onUpdate(_) {
    value = _combiner();
  }

  @override
  void dispose() {
    for (final source in _sources) {
      source.removeListener(_onUpdate);
    }
    super.dispose();
  }
}
