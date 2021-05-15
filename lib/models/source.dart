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
}
