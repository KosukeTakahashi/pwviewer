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
      this.name, this.website, this.vapidKey, this.clientId, this.clientSecret);
}
