import 'package:pwviewer/utils/maybe.dart';

import 'history.dart';

class Tag {
  // Base attributes
  String name;
  String url;

  // Optional attributes
  List<History>? history;

  Tag(
    this.name,
    this.url,
    this.history,
  );

  Tag.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        url = json['url'],
        history = Maybe<List<dynamic>>.some(json['history'])
            .map((v) => v
                .cast<Map<String, dynamic>>()
                .map((e) => History.fromJson(e))
                .cast<History>()
                .toList())
            .unwrapOrNull();
}
