class Maybe<T> {
  T? value;

  Maybe.some(T? value) {
    if (value == null) {
      Maybe.nothing();
    } else {
      this.value = value;
    }
  }

  Maybe.nothing() : value = null;

  T unwrap() {
    if (this.value == null) {
      throw StateError('this.value is null');
    } else {
      return this.value!;
    }
  }

  T? unwrapOrNull() {
    return this.value;
  }

  bool isNothing() {
    return value == null;
  }

  Maybe<U> map<U>(U Function(T) projection) {
    return this.value == null
        ? Maybe<U>.nothing()
        : Maybe<U>.some(projection(this.value!));
  }
}
