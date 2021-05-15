enum Type {
  unknown,
  image,
  gifv,
  video,
  audio,
}

extension on Type {
  String get name => this.toString().split('.').last;
}

class ToType {
  static fromString(String value) =>
      Type.values.firstWhere((element) => element.name == value);
}
