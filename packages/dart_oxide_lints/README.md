A strict set of lints to be used alongside other dart-oxide packages.
Modified from [extra_pedantic](https://github.com/modulovalue/extra_pedantic/tree/master).

# Features

- As strong of type checks as dart will allow
- Lints to encourage better code style
- Automatically ignores common generated files (_.g.dart, _.freezed.dart)
- Lints exposing potentially incorrect behavior configured to errors instead of warnings

# Usage

To use the configured lints, include this package's configuration in your `analysis_options.yaml`

```yaml
include: package:dart_oxide_lints/analysis_options.yaml
```

Note that this package **MUST** be a dev dependency of each package that depends on these lints.
This means that in a monorepo using a single top-level `analysis_options.yaml`, this package
must be added as a dev dependency to the top level package, and separately to each individual package in the
monorepo.
