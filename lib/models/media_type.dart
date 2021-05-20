enum MediaType {
  unknown,
  image,
  gifv,
  video,
  audio,
}

extension on MediaType {
  String get name => this.toString().split('.').last;
}

class ToMediaType {
  static fromString(String value) =>
      MediaType.values.firstWhere((element) => element.name == value);
}
