enum NotificationType {
  follow,
  follow_request,
  mention,
  reblog,
  favourite,
  poll,
  status,
}

extension on NotificationType {
  String get name => this.toString().split('.').last;
}

class ToNotificationType {
  static NotificationType fromString(String value) =>
      NotificationType.values.firstWhere((element) => element.name == value);
}
