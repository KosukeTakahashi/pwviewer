class Emoji {
  // Required attributes
  String shortcode;
  String url;
  String staticUrl;
  bool visibleInPicker;

  // Optional attributes
  String? category;

  Emoji(
    this.shortcode,
    this.url,
    this.staticUrl,
    this.visibleInPicker,
    this.category,
  );
}
