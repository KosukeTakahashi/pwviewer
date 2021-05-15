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
}
