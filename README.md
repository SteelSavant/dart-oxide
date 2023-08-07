Dart-Oxide is a set of types, extensions, and other utilities for making Dart a little Rustier. Inspiration is taken from C# and other garbage collected languages as well,
as an acknowledgement that Dart is garbage collected, and certain patterns and practices aren't possible/practical in a garbage collected environment.

### Alternatives

This package provides some of the same types as [fpdart](https://pub.dev/packages/fpdart), with similar motivations behind them, however Dart-Oxide is a less drastic paradigm shift into full functional programming. Instead, Dart-Oxide seeks to apply certain principles inspired by functional programming, while still intending for users to otherwise utilize standard Dart idioms and practices.

## Features

### Types

- `Option<T>`, an alternative to `T?`, which provides a variety of methods and extensions to provide additional functionality. Unlike `T?`, it is composable, i.e. `Option<Option<T>>` is a valid type. It provides a `Some(T)` variant to represent a value, and a `None` variant if no value is present.
- `Result<R, E>` type, to make error handling more explicit. It prevents scenarios where bugs can be introduced if a `throw` is introduced in a called function, but the calling code is not updated to `try/catch` the new exception. It provides an `Ok(R)` variant if successful, and an `Err(E)` variant if there was an error.
- `Newtype`, a basic wrapper around any type that is guaranteed not to unify with the original type. Only useful for simple types (like Ids), since no methods or operators can be forwarded to the new type. Will likely be replaced by [extension types](https://github.com/dart-lang/language/issues/2727) when the feature is complete.

### Resource Management

- A set of interfaces for disposable objects (`IDisposable` and `IFutureDisposable<U>`). `IFutureDisposable<U>` is generic over the return type to allow it to `U` to represent a `Future`, `FutureOr`, or to unify with the synchronous `IDisposable`.
- Static `using` and `usingAsync` functions to perform an action on a disposable resource and guarantee the resource is disposed afterwards (as in C#)
- a `Box<T, U>` type that can store a resource and provide protected access based on whether the resource has been disposed or not. `Box` is generic over whether or not the dispose method is async. Additionally, a `Box` can be attached to a `Finalizer` so that the resource is disposed when the `Box` is garbage collected.
- an `Rc<T, U>` type, similar to `Box`, except that an `Rc` can be cloned, and the protected resource will only be disposed when the last `Rc` is disposed. Useful for managing the lifetime of shared resources that require proper disposal. Like `Box`, `Rc` is generic over whether or not the dispose method is async, and can be attached to a `Finalizer` so that the resource is disposed when the `Rc` is garbage collected.
- a `Ptr<T>` type, used to pass a reference to a mutatable (usually primitive) value.

## Usage

Refer to the class and method documentation, or the tests, for basic usage.
