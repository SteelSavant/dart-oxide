/// A reference to a value. This can be used to pass primitive/immutable values by reference, and mutate them in-place.
class Ref<T> {
  Ref(this.value);

  T value;
}
