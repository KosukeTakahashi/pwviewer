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

  Emoji.fromJson(Map<String, dynamic> json)
      : shortcode = json['shortcode'],
        url = json['url'],
        staticUrl = json['static_url'],
        visibleInPicker = json['visible_in_picker'],
        category = json['category'];
}
