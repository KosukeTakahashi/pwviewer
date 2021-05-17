import 'package:pwviewer/models/account.dart';
import 'package:pwviewer/models/status.dart';
import 'package:pwviewer/models/tag.dart';

class Results {
  List<Account> accounts;
  List<Status> statuses;
  List<Tag> hashtags;

  Results(
    this.accounts,
    this.statuses,
    this.hashtags,
  );

  Results.fromJson(Map<String, dynamic> json)
      : accounts = json['accounts']
            .cast<Map<String, dynamic>>()
            .map((e) => Account.fromJson(e))
            .cast<Account>()
            .toList(),
        statuses = json['statuses']
            .cast<Map<String, dynamic>>()
            .map((e) => Status.fromJson(e))
            .cast<Status>()
            .toList(),
        hashtags = json['hashtags']
            .cast<Map<String, dynamic>>()
            .map((e) => Tag.fromJson(e))
            .cast<Tag>()
            .toList();
}
