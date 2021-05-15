import 'account.dart';
import 'visibility.dart';
import 'attachment.dart';
import 'application.dart';

class State {
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
  Application application;

  // Rendering attributes
  // List<Mention> mentions;
  // List<Tag> tags;
  // List<Emoji> emojis;

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
  bool favourited;
  bool muted;
  bool bookmarked;
  bool pinned;

  State(
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
      // this.mentions,
      // this.tags,
      // this.emojis,
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
      this.pinned);
}
