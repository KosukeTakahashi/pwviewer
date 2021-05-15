import 'field.dart';
import 'privacy.dart';

class Source {
  // Base attributes
  String note;
  List<Field> fields;

  // Nullable attributes
  Privacy? privacy;
  bool? sensitive;
  String? language;
  int? followRequestsCount;

  Source(
    this.note,
    this.fields,
    this.privacy,
    this.sensitive,
    this.language,
    this.followRequestsCount,
  );

  Source.fromJson(Map<String, dynamic> json)
      : note = json['note'],
        fields = json['fields']
            .cast<List<Map<String, dynamic>>>()
            .map((e) => Field.fromJson(e))
            .cast<Field>()
            .toList(),
        privacy = ToPrivacy.fromString(json['privacy']),
        sensitive = json['sensitive'],
        language = json['language'],
        followRequestsCount = json['follow_request_count'];
}
