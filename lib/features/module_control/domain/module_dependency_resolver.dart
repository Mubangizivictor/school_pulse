import 'module_registry.dart';

class ModuleDependencyResolver {
  const ModuleDependencyResolver();
  List<ModuleDefinition> missing(
    ModuleDefinition module,
    Set<String> enabled,
  ) => module.dependencies
      .where((key) => !enabled.contains(key))
      .map(ModuleRegistry.byKey)
      .toList();
  List<ModuleDefinition> dependentsOf(String key, Set<String> enabled) =>
      ModuleRegistry.all
          .where(
            (item) =>
                enabled.contains(item.key) && item.dependencies.contains(key),
          )
          .toList();
}
