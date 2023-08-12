A strict set of lints to be used alongside other dart-oxide packages.
Modified from [extra_pedantic](https://github.com/modulovalue/extra_pedantic/tree/master).

# Features

- As strong of type checks as dart will allow
- Lints to encourage better code style
- Automatically ignores common generated files (*.g.dart, *.freezed.dart)
- Lints exposing potentially incorrect behavior configured to errors instead of warnings

# Usage

To use the configured lints, include this package's configuration in your `analysis_options.yaml`

```yaml
include: package:dart_oxide_lints/analysis_options.yaml
```

The `include` function in `analysis_options.yaml` does not seem to apply values in the `exclude` or `errors` sections. To use the configured warning/error levels and ignore common generated files, copy the sections from the source of the `analysis_options.yaml` in this repository into your `analysis_options.yaml`.

```
include: package:dart_oxide_lints/analysis_options.yaml
analyzer:
  exclude:
    - '**/*.freezed.dart'
    - '**/*.g.dart'
  errors:
    # error
    always_declare_return_types: error
    avoid_dynamic_calls: error
    avoid_equals_and_hash_code_on_mutable_classes: error
    avoid_shadowing_type_parameters: error
    avoid_type_to_string: error
    avoid_types_as_parameter_names: error
    avoid_web_libraries_in_flutter: error
    await_only_futures: error
    body_might_complete_normally: error
    body_might_complete_normally_catch_error: error
    body_might_complete_normally_nullable: error
    collection_methods_unrelated_type: error
    discarded_futures: error
    exhaustive_cases: error
    hash_and_equals: error
    implementation_imports: error
    implicit_reopen: error
    invalid_case_patterns: error
    invalid_non_virtual_annotation: error
    invalid_override_of_non_virtual_member: error
    invalid_use_of_protected_member: error
    iterable_contains_unrelated_type: error
    inference_failure_on_function_invocation: error
    inference_failure_on_function_return_type: error 
    inference_failure_on_collection_literal: error
    inference_failure_on_generic_invocation: error
    inference_failure_on_instance_creation: error
    inference_failure_on_uninitialized_variable: error 
    inference_failure_on_untyped_parameter: error
    list_remove_unrelated_type: error
    must_be_immutable: error
    must_call_super: error
    no_duplicate_case_values: error
    # no_self_assignments: error
    # no_wildcard_parameter_uses: error
    null_closures: error
    only_throw_errors: error
    recursive_getters: error
    strict_raw_type: error
    test_types_in_equals: error
    type_literal_in_constant_pattern: error
    unawaited_futures: error
    unrelated_type_equality_checks: error
    use_build_context_synchronously: error
    valid_regexps: error

    # warning
    avoid_implementing_value_types: warning
    avoid_js_rounded_ints: warning
    avoid_positional_boolean_parameters: warning
    avoid_slow_async_io: warning
    cancel_subscriptions: warning
    close_sinks: warning
    
    prefer_typing_uninitialized_variables: warning
    type_annotate_public_apis: warning

    # ignore
    todo: ignore
    invalid_annotation_target: ignore # required by freezed
```


