enum Visibility {
  public,
  unlisted,
  private,
  direct,
}

extension on Visibility {
  String get name => this.toString().split('.').last;
}

class ToVisibility {
  static fromString(String value) =>
      Visibility.values.firstWhere((element) => element.name == value);
}
