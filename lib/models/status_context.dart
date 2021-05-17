import 'status.dart';

class StatusContext {
  final List<Status> ancestors;
  final List<Status> descendants;

  StatusContext(
    this.ancestors,
    this.descendants,
  );

  StatusContext.fromJson(Map<String, dynamic> json)
      : ancestors = json['ancestors']
            .cast<Map<String, dynamic>>()
            .map((e) => Status.fromJson(e))
            .cast<Status>()
            .toList(),
        descendants = json['descendants']
            .cast<Map<String, dynamic>>()
            .map((e) => Status.fromJson(e))
            .cast<Status>()
            .toList();
}
