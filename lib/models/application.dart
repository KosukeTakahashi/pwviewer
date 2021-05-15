class Application {
  // Required attributes
  String name;

  // Optional attributes
  String? website;
  String? vapidKey;

  // Client attributes
  String? clientId;
  String? clientSecret;

  Application(
    this.name,
    this.website,
    this.vapidKey,
    this.clientId,
    this.clientSecret,
  );

  Application.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        website = json['website'],
        vapidKey = json['vapid_key'],
        clientId = json['client_id'],
        clientSecret = json['client_secret'];
}
