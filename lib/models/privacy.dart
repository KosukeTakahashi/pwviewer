enum Privacy {
  public,
  unlisted,
  private,
  direct,
}

extension on Privacy {
  String get name => this.toString().split('.').last;
}

class ToPrivacy {
  static fromString(String value) =>
      Privacy.values.firstWhere((element) => element.name == value);
}
