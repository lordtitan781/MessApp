class SpecialDinnerToken {
  final bool hasEaten;
  final DateTime? redeemedAt;

  SpecialDinnerToken({required this.hasEaten, this.redeemedAt});


  Map<String, dynamic> toMap() {
    return {
      "hasEaten": hasEaten,
      "redeemedAt": redeemedAt?.toIso8601String(),
    };
  }

  factory SpecialDinnerToken.fromMap(Map<String, dynamic> map) {
    return SpecialDinnerToken(
      hasEaten: map["hasEaten"] ?? false,
      redeemedAt: map["redeemedAt"] != null
          ? DateTime.parse(map["redeemedAt"])
          : null,
    );
  }
}
