import 'media_type.dart';

class Attachment {
  // Required attributes
  String id;
  MediaType type;
  String url;
  String previewUrl;

  // Optional attributes
  String? remoteUrl;
  String? textUrl;
  dynamic? meta;
  String? description;
  String? blurhash;

  Attachment(
    this.id,
    this.type,
    this.url,
    this.previewUrl,
    this.remoteUrl,
    this.textUrl,
    this.meta,
    this.description,
    this.blurhash,
  );

  Attachment.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        type = ToMediaType.fromString(json['type']),
        url = json['url'],
        previewUrl = json['preview_url'],
        remoteUrl = json['remote_url'],
        textUrl = json['text_url'],
        meta = json['meta'],
        description = json['description'],
        blurhash = json['blurhash'];
}
