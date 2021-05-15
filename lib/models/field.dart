class Field {
  // Required attributes
  String name;
  String value;

  // Optional attributes
  String? verifiedAt;

  Field(
    this.name,
    this.value,
    this.verifiedAt,
  );

  Field.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        value = json['value'],
        verifiedAt = json['verified_at'];
}
