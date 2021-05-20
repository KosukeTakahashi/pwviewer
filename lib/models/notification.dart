import 'package:pwviewer/models/account.dart';
import 'package:pwviewer/models/notification_type.dart';
import 'package:pwviewer/models/status.dart';
import 'package:pwviewer/utils/maybe.dart';

class Notification {
  // Required attributes
  String id;
  NotificationType type;
  String createdAt;
  Account account;

  // Optional attributes
  Status? status;

  Notification(this.id, this.type, this.createdAt, this.account, this.status);

  Notification.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        type = ToNotificationType.fromString(json['type']),
        createdAt = json['created_at'],
        account = Account.fromJson(json['account']),
        status = Maybe<Map<String, dynamic>>.some(json['status'])
            .map((v) => Status.fromJson(v))
            .unwrapOrNull();
}
