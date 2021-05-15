class History {
  // Required attributes
  String day;
  String uses;
  String accounts;

  History(
    this.day,
    this.uses,
    this.accounts,
  );

  History.fromJson(Map<String, dynamic> json)
      : day = json['day'],
        uses = json['uses'],
        accounts = json['accounts'];
}
