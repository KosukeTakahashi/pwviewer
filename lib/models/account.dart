import 'emoji.dart';
import 'field.dart';
import 'source.dart';
import '../utils/maybe.dart';

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
  List<Emoji> emojis;
  bool? discoverable; // v3.1.0 or higher

  // Statistical attributes
  String createdAt;
  String lastStatusAt;
  int statusesCount;
  int followersCount;
  int followingCount;

  // Optional attributes
  Account? moved;
  List<Field>? fields;
  bool? bot;
  Source? source;
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
    this.emojis,
    this.discoverable,
    this.createdAt,
    this.lastStatusAt,
    this.statusesCount,
    this.followersCount,
    this.followingCount,
    this.moved,
    this.fields,
    this.bot,
    this.source,
    this.suspended,
    this.muteExpiresAt,
  );

  Account.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'],
        acct = json['acct'],
        url = json['url'],
        displayName = json['display_name'],
        note = json['note'],
        avatar = json['avatar'],
        avatarStatic = json['avatar_static'],
        header = json['header'],
        headerStatic = json['header_static'],
        locked = json['locked'],
        emojis = json['emojis']
            .cast<Map<String, dynamic>>()
            .map((e) => Emoji.fromJson(e))
            .cast<Emoji>()
            .toList(),
        discoverable = json['discoverable'],
        createdAt = json['created_at'],
        lastStatusAt = json['last_status_at'],
        statusesCount = json['statuses_count'],
        followersCount = json['followers_count'],
        followingCount = json['following_count'],
        moved = Maybe<Map<String, dynamic>>.some(json['moved'])
            .map((v) => Account.fromJson(v))
            .unwrapOrNull(),
        fields = json['fields']
            .cast<Map<String, dynamic>>()
            .map((e) => Field.fromJson(e))
            .cast<Field>()
            .toList(),
        bot = json['bot'],
        source = json['source'],
        suspended = json['suspended'],
        muteExpiresAt = json['mute_expires_at'];
}
