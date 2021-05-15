class Account {
  // Base attributes
  String id;
  String username;
  String acct;
  String url;

  // Display attributes
  String displayName;
  String note;
  String avatar;
  String avatarStatic;
  String header;
  String headerStatic;
  bool locked;
  // List<Emoji> emojis;
  bool discoverable;

  // Statistical attributes
  String createdAt;
  String lastStatusAt;
  int statuesCount;
  int followersCount;
  int followingCount;

  // Optional attributes
  // Account? moved;
  // List<Field>? fields;
  bool? bot;
  // Source? source;
  bool? suspended;
  String? muteExpiresAt;

  Account(
      this.id,
      this.username,
      this.acct,
      this.url,
      this.displayName,
      this.note,
      this.avatar,
      this.avatarStatic,
      this.header,
      this.headerStatic,
      this.locked,
      // this.emojis,
      this.discoverable,
      this.createdAt,
      this.lastStatusAt,
      this.statuesCount,
      this.followersCount,
      this.followingCount,
      // this.moved,
      // this.fields,
      this.bot,
      // this.source,
      this.suspended,
      this.muteExpiresAt);
}
