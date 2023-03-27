import 'package:freezed_annotation/freezed_annotation.dart';

/// Makes a new type that wraps an existing one; does not unify with the base type, or other newtypes with different `[TBrand]` types.
/// Useful for supplying semantic meaning to other constructs at the type level, such as for ids.
///
/// Example usage:
/// ```
/// abstract class _AccountBrand {}
/// typedef AccountId = NewType<int, _AccountBrand>
///
/// abstract class _UserBrand {}
/// typedef UserId = NewType<int, _UserBrand>
///
/// assert(AccountId(5) != UserId(5))
/// ```
@immutable
class NewType<TItem, TBrand> {
  final TItem item;
  const NewType(this.item);

  @override
  int get hashCode => item.hashCode;
  @override
  bool operator ==(Object? other) =>
      other is NewType<TItem, TBrand> && other.item == item;
}
