class User {
  final int? id;  // جعل ال id اختياري
  final String name;
  final String gender;
  final int age;
  final String email;
  final String mobileNumber;

  User({
    this.id,  // جعل ال id اختياري في ال constructor
    required this.name,
    required this.gender,
    required this.age,
    required this.email,
    required this.mobileNumber,
  });

  // Convert User instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'age': age,
      'email': email,
      'mobileNumber': mobileNumber,
    };
  }

  // Create User instance from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String,
      gender: json['gender'] as String,
      age: json['age'] as int,
      email: json['email'] as String,
      mobileNumber: json['mobileNumber'] as String,
    );
  }
}
