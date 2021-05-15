class Mention {
  // Required attributes
  String id;
  String username;
  String acct;
  String url;

  Mention(
    this.id,
    this.username,
    this.acct,
    this.url,
  );

  Mention.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'],
        acct = json['acct'],
        url = json['acct'];
}
