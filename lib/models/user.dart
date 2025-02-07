class User {
  final int? id;  
  final String name;
  final String? gender;
  final int? age;
  final String email;
  final String? mobileNumber;
  final String? profileImagePath;
  final String password;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.name,
    this.gender,
    this.age,
    required this.email,
    this.mobileNumber,
    this.profileImagePath,
    required this.password,
    this.createdAt,
    this.updatedAt,
  });

  User copyWith({
    int? id,
    String? name,
    String? gender,
    int? age,
    String? email,
    String? mobileNumber,
    String? profileImagePath,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // For internal use (includes password)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'age': age,
      'email': email,
      'mobile_number': mobileNumber,
      'profile_image_path': profileImagePath,
      'password': password,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // For API responses (excludes password)
  Map<String, dynamic> toResponseJson() {
    String? profileImageUrl;
    if (profileImagePath != null && profileImagePath!.isNotEmpty) {
      // Convert the relative path to a full URL
      profileImageUrl = '/static/$profileImagePath';
    }

    return {
      'id': id,
      'name': name,
      'gender': gender,
      'age': age,
      'email': email,
      'mobile_number': mobileNumber,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      email: json['email'] as String,
      mobileNumber: json['mobile_number'] as String?,
      profileImagePath: json['profile_image_path'] as String?,
      password: json['password'] as String,
      createdAt: json['created_at'] != null 
          ? json['created_at'] is String 
              ? DateTime.parse(json['created_at'] as String)
              : json['created_at'] as DateTime
          : null,
      updatedAt: json['updated_at'] != null
          ? json['updated_at'] is String
              ? DateTime.parse(json['updated_at'] as String)
              : json['updated_at'] as DateTime
          : null,
    );
  }
}
