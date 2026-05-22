import 'address.dart';

class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String photoUrl;
  final List<Address> addresses;
  final List<String> favoriteItems;

  const UserProfile({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.photoUrl = '',
    this.addresses = const [],
    this.favoriteItems = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    var addrList = <Address>[];
    if (json['addresses'] != null) {
      addrList = (json['addresses'] as List)
          .map((item) =>
              Address.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    var favList = <String>[];
    if (json['favoriteItems'] != null) {
      favList = List<String>.from(json['favoriteItems'] as List);
    }

    return UserProfile(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      addresses: addrList,
      favoriteItems: favList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'photoUrl': photoUrl,
      'addresses': addresses.map((a) => a.toJson()).toList(),
      'favoriteItems': favoriteItems,
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? photoUrl,
    List<Address>? addresses,
    List<String>? favoriteItems,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      photoUrl: photoUrl ?? this.photoUrl,
      addresses: addresses ?? this.addresses,
      favoriteItems: favoriteItems ?? this.favoriteItems,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.address == address &&
        other.photoUrl == photoUrl &&
        other.addresses == addresses &&
        other.favoriteItems == favoriteItems;
  }

  @override
  int get hashCode {
    return Object.hash(
        name, email, phone, address, photoUrl, addresses, favoriteItems);
  }

  @override
  String toString() {
    return 'UserProfile(name: $name, email: $email, phone: $phone, addressesCount: ${addresses.length})';
  }
}
