import '../utils/parsers.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.address,
    required this.photo,
    required this.dateJoined,
  });

  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String address;
  final String? photo;
  final String? dateJoined;

  String get fullName {
    final combined = '$firstName $lastName'.trim();
    return combined.isEmpty ? username : combined;
  }

  String get initial {
    final source = fullName.trim();
    return source.isEmpty ? 'Q' : source[0].toUpperCase();
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: asInt(json['id']),
      username: asString(json['username']),
      email: asString(json['email']),
      firstName: asString(json['first_name']),
      lastName: asString(json['last_name']),
      phone: asString(json['phone']),
      address: asString(json['address']),
      photo: json['photo'] == null ? null : asString(json['photo']),
      dateJoined: json['date_joined'] == null
          ? null
          : asString(json['date_joined']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'address': address,
      'photo': photo,
      'date_joined': dateJoined,
    };
  }
}
