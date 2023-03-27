import 'package:meta/meta_meta.dart';

// TODO::description of visibility rules, including defaults

/// Declares visibility for the library.
@Target({TargetKind.library})
class Pub {
  final String path;
  const Pub(this.path);
}
