import '../services/api/api_endpoints.dart';

class UserModel {
  final String id;
  final String firstName;
  final String? lastName;
  final String email;
  final String? phoneNumber;
  final String? gender;
  final String? dateOfBirth;
  final String? profilePhotoUrl;
  final UserAddress? address;
  final String token;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.email,
    this.phoneNumber,
    this.gender,
    this.dateOfBirth,
    this.profilePhotoUrl,
    this.address,
    required this.token,
    this.createdAt,
  });

  // Keep this getter or field for backward compatibility
  String get username => (lastName != null && lastName!.isNotEmpty)
      ? '$firstName $lastName'
      : firstName;

  String get fullName => username;

  // Convert JSON map to UserModel instance (handling both mock storage and API structures)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // If the JSON contains a nested 'user' key (like the API response)
    final userMap = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;

    // Parse first/last name, fallback to parsing 'username' if firstName is missing
    String firstName = userMap['firstName'] as String? ?? '';
    String? lastName = userMap['lastName'] as String?;

    if (firstName.isEmpty && userMap['username'] != null) {
      final parts = (userMap['username'] as String).split(' ');
      firstName = parts.first;
      if (parts.length > 1) {
        lastName = parts.sublist(1).join(' ');
      }
    }

    // Parse Address
    UserAddress? parsedAddress;
    final addressJson = userMap['userAddress'] ?? userMap['address'];
    if (addressJson != null && addressJson is Map<String, dynamic>) {
      parsedAddress = UserAddress.fromJson(addressJson);
    } else if (addressJson is String && addressJson.isNotEmpty) {
      parsedAddress = UserAddress(streetAddress: addressJson);
    }

    // Parse Photo
    String? photoUrl;
    if (userMap['profilePhoto'] != null &&
        userMap['profilePhoto'] is Map<String, dynamic>) {
      photoUrl =
          userMap['profilePhoto']['url'] as String? ??
          userMap['profilePhoto']['path'] as String?;
    } else if (userMap['profilePhoto'] is String) {
      photoUrl = userMap['profilePhoto'] as String;
    } else if (userMap['profilePhotoUrl'] != null) {
      photoUrl = userMap['profilePhotoUrl'] as String?;
    } else if (userMap['avatar'] != null) {
      photoUrl = userMap['avatar'] as String?;
    }

    if (photoUrl != null &&
        photoUrl.isNotEmpty &&
        !photoUrl.startsWith('http')) {
      final baseUrl = ApiEndpoints.baseUrl.endsWith('/')
          ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
          : ApiEndpoints.baseUrl;
      final path = photoUrl.startsWith('/') ? photoUrl : '/$photoUrl';
      photoUrl = '$baseUrl$path';
    }

    // Extract access token from various possible JSON response structures
    final token =
        json['accessToken'] as String? ??
        json['access_token'] as String? ??
        json['token'] as String? ??
        json['jwt'] as String? ??
        json['bearerToken'] as String? ??
        (json['data'] is Map ? json['data']['token'] as String? : null) ??
        (json['data'] is Map ? json['data']['accessToken'] as String? : null) ??
        (json['data'] is Map
            ? json['data']['access_token'] as String?
            : null) ??
        userMap['token'] as String? ??
        userMap['accessToken'] as String? ??
        userMap['access_token'] as String? ??
        '';

    return UserModel(
      id: (userMap['id'] ?? userMap['_id'] ?? '').toString(),
      firstName: firstName,
      lastName: lastName,
      email: userMap['email'] as String? ?? '',
      phoneNumber:
          userMap['phoneNumber'] as String? ?? userMap['phone'] as String?,
      gender: userMap['gender'] as String?,
      dateOfBirth:
          userMap['dateOfBirth'] as String? ?? userMap['dob'] as String?,
      profilePhotoUrl: photoUrl,
      address: parsedAddress,
      token: token,
      createdAt: userMap['createdAt'] as String?,
    );
  }

  // Convert UserModel instance to JSON map (saving everything flat/standard for StorageService)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'profilePhotoUrl': profilePhotoUrl,
      'address': address?.toJson(),
      'token': token,
      'createdAt': createdAt,
    };
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? gender,
    String? dateOfBirth,
    String? profilePhotoUrl,
    bool clearProfilePhoto = false,
    UserAddress? address,
    String? token,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profilePhotoUrl: clearProfilePhoto
          ? null
          : (profilePhotoUrl ?? this.profilePhotoUrl),
      address: address ?? this.address,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper method for empty or mock user
  factory UserModel.empty() {
    return UserModel(id: '', firstName: '', email: '', token: '');
  }
}

class UserAddress {
  final String streetAddress;
  final String? postalCode;
  final String? city;
  final String? province;
  final String? country;

  UserAddress({
    required this.streetAddress,
    this.postalCode,
    this.city,
    this.province,
    this.country,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      streetAddress: json['streetAddress'] as String? ?? '',
      postalCode: json['postalCode'] as String?,
      city: json['city'] as String?,
      province: json['province'] as String?,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streetAddress': streetAddress,
      'postalCode': postalCode,
      'city': city,
      'province': province,
      'country': country,
    };
  }
}
