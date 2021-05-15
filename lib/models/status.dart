import 'package:pwviewer/utils/maybe.dart';

import 'account.dart';
import 'visibility.dart';
import 'attachment.dart';
import 'application.dart';
import 'mention.dart';
import 'tag.dart';
import 'emoji.dart';

class Status {
  // Base attributes
  String id;
  String uri;
  String createdAt;
  Account account;
  String content;
  Visibility visibility;
  bool sensitive;
  String spoilerText;
  List<Attachment> mediaAttachments;
  Application? application; // 含まれない場合がある？

  // Rendering attributes
  List<Mention> mentions;
  List<Tag> tags;
  List<Emoji> emojis;

  // Informational attributes
  int reblogsCount;
  int favouritesCount;
  int repliesCount;

  // Nullable attributes
  String? url;
  String? inReplyToId;
  String? inReplyToAccountId;
  // Status? reblog;
  // Poll? poll;
  // Card? card;
  String? language;
  String? text;

  // Authorized user attributes
  bool? favourited;
  bool? muted;
  bool? bookmarked;
  bool? pinned;

  Status(
    this.id,
    this.uri,
    this.createdAt,
    this.account,
    this.content,
    this.visibility,
    this.sensitive,
    this.spoilerText,
    this.mediaAttachments,
    this.application,
    this.mentions,
    this.tags,
    this.emojis,
    this.reblogsCount,
    this.favouritesCount,
    this.repliesCount,
    this.url,
    this.inReplyToId,
    this.inReplyToAccountId,
    this.language,
    this.text,
    this.favourited,
    this.muted,
    this.bookmarked,
    this.pinned,
  );

  Status.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        uri = json['uri'],
        createdAt = json['created_at'],
        account = Account.fromJson(json['account']),
        content = json['content'],
        visibility = ToVisibility.fromString(json['visibility']),
        sensitive = json['sensitive'],
        spoilerText = json['spoiler_text'],
        mediaAttachments = json['media_attachments']
            .cast<Map<String, dynamic>>()
            .map((e) => Attachment.fromJson(e))
            .cast<Attachment>()
            .toList(),
        application = Maybe<Map<String, dynamic>>.some(json['application'])
            .map((v) => Application.fromJson(v))
            .unwrapOrNull(),
        mentions = json['mentions']
            .cast<Map<String, dynamic>>()
            .map((e) => Mention.fromJson(e))
            .cast<Mention>()
            .toList(),
        tags = json['tags']
            .cast<Map<String, dynamic>>()
            .map((e) => Tag.fromJson(e))
            .cast<Tag>()
            .toList(),
        emojis = json['emojis']
            .cast<Map<String, dynamic>>()
            .map((e) => Emoji.fromJson(e))
            .cast<Emoji>()
            .toList(),
        reblogsCount = json['reblogs_count'],
        favouritesCount = json['favourites_count'],
        repliesCount = json['replies_count'],
        url = json['url'],
        inReplyToId = json['in_reply_to_id'],
        inReplyToAccountId = json['in_reply_to_account_id'],
        language = json['language'],
        text = json['text'],
        favourited = json['favourited'],
        muted = json['muted'],
        bookmarked = json['bookmarked'],
        pinned = json['pinned'];
}
