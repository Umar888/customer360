class Address {
  Address({
    required this.name,
    required this.address,
  });

  String name;
  String address;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        name: json["name"],
        address: json["address"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "address": address,
      };
}
