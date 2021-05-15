class Attachment {
  // Required attributes
  String id;
  // Type type;
  String url;
  String previewUrl;

  // Optional attributes
  String? remoteUrl;
  String? textUrl;
  // Hash? meta;
  String? description;
  String? blurhash;

  Attachment(
    this.id,
    // this.type,
    this.url,
    this.previewUrl,
    this.remoteUrl,
    this.textUrl,
    // this.meta,
    this.description,
    this.blurhash,
  );
}
