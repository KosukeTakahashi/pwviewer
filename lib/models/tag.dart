import 'history.dart';

class Tag {
  // Base attributes
  String name;
  String url;

  // Optional attributes
  History? history;

  Tag(
    this.name,
    this.url,
    this.history,
  );
}
