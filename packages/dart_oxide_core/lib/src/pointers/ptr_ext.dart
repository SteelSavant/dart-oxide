import 'dart:async';

import 'package:dart_oxide_core/pointers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// TODO::annotation to force users to box/cell constructed disposable types

extension IDisposableExt<T extends IDisposable> on T {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  Box<T, ()> toBox() => Box.fromDisposable(this);

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  Cell<T, ()> toCell() => Cell.fromDisposable(this);
}

extension IAsyncDisposableExt<T extends IAsyncDisposable> on T {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  Box<T, FutureOr<()>> toBox() => Box.fromAsyncDisposable(this);

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  Cell<T, FutureOr<()>> toCell() => Cell.fromAsyncDisposable(this);
}
