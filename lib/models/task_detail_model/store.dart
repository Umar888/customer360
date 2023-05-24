class Store {
  final String id;
  final String? name;
  final String? drivingDirections;
  final String? storeId;

  Store._({
    required this.id,
    this.name,
    this.drivingDirections,
    this.storeId,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store._(
      id: json['Id'],
      name: json['Name'],
    );
  }
}
