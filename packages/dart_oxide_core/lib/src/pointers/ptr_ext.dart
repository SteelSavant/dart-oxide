import 'dart:async';

import 'package:dart_oxide_core/pointers.dart';
import 'package:dart_oxide_core/types.dart';
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

extension OptionPtrExt<T> on Ptr<Option<T>> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  Option<T> take() {
    final option = value;
    value = Option<T>.none();
    return option;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  Option<T> replace(T value) {
    final old = this.value;
    this.value = Option.some(value);
    return old;
  }
}

extension NullPtrExt<T> on Ptr<T?> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  T? take() {
    final value = this.value;
    this.value = null;
    return value;
  }
}

extension PtrExt<T> on Ptr<T> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  T replace(T value) {
    final old = this.value;
    this.value = value;
    return old;
  }
}
