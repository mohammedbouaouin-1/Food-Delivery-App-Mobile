class Address {
  final String id;
  final String label; // e.g., 'Maison', 'Bureau'
  final String address;
  final String city;
  final bool isDefault;

  const Address({
    required this.id,
    required this.label,
    required this.address,
    required this.city,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'address': address,
      'city': city,
      'isDefault': isDefault,
    };
  }

  Address copyWith({
    String? id,
    String? label,
    String? address,
    String? city,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      address: address ?? this.address,
      city: city ?? this.city,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Address &&
        other.id == id &&
        other.label == label &&
        other.address == address &&
        other.city == city &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode {
    return Object.hash(id, label, address, city, isDefault);
  }

  @override
  String toString() {
    return 'Address(id: $id, label: $label, address: $address, city: $city, isDefault: $isDefault)';
  }
}
