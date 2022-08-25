import 'package:ab_testing_core/src/adapter.dart';
import 'package:ab_testing_core/src/experiment.dart';

abstract class ExperimentsLogger {
  void log(String message);
  void logExperiments(List<Experiment> experiments);
}

class ExperimentsConfig {
  final List<ExperimentsAdapter> _adapters;
  final ExperimentsLogger? _logger;

  ExperimentsConfig(this._adapters, [this._logger]);

  List<Experiment> get _allExperiments => _adapters.expand((adapter) => adapter.experiments).toList();
  List<Experiment> get experiments => _allExperiments.where((value) => value.active).toList();

  Future<void> init() async {
    await Future.wait(_adapters.map((adapter) => adapter.init()));
    update();
    _logger?.logExperiments(experiments);
  }

  Future<void> update({bool force = false}) async {
    final adapters = _adapters.whereType<UpdatableExperimentsAdapter>();
    if (adapters.isNotEmpty) {
      await Future.wait(adapters.map((adapter) => adapter.update(force: force)));
    }
    _logger?.logExperiments(experiments);
  }

  Map<String, String> asMap() => {for (var item in _allExperiments) item.id: item.stringValue};
}
