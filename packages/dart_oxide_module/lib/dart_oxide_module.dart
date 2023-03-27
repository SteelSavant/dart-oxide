/// Support for modules/module visibility modifiers for dart libraries, by means of a custom lint and annotations.
library dart_oxide_module;

import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

// This is the entrypoint of our custom linter
PluginBase createPlugin() => _OxideModuleLinter();

/// A plugin class is used to list all the assists/lints defined by a plugin.
class _OxideModuleLinter extends PluginBase {
  /// We list all the custom warnings/infos/errors
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        OxideModuleCode(),
      ];
}

class OxideModuleCode extends DartLintRule {
  OxideModuleCode() : super(code: _code);

  /// Metadata about the warning that will show-up in the IDE.
  /// This is used for `// ignore: code` and enabling/disabling the lint
  static const _code = LintCode(
    name: 'use_of_private_module',
    problemMessage: 'The module you are trying to use is private.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addExportDirective((node) {
      reporter.reportErrorForNode(code, node);
    });
    // Our lint will highlight all variable declarations with our custom warning.
    context.registry.addImportDirective((node) {
      reporter.reportErrorForNode(code, node);
    });
  }
}
