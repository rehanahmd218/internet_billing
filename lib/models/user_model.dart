class UserModel {
  final int? id;
  final int no; // Sequential number (auto-generated)
  final String uid; // User-provided unique identifier
  final String name;
  final String mobileNumber;
  final String address;
  final DateTime createdDate;
  final bool isActive;

  UserModel({
    this.id,
    required this.no,
    required this.uid,
    required this.name,
    required this.mobileNumber,
    required this.address,
    required this.createdDate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'no': no,
      'uid': uid,
      'name': name,
      'mobile_number': mobileNumber,
      'address': address,
      'created_date': createdDate.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      no: map['no'] as int,
      uid: map['uid'] as String,
      name: map['name'] as String,
      mobileNumber: map['mobile_number'] as String,
      address: map['address'] as String,
      createdDate: DateTime.parse(map['created_date'] as String),
      isActive: (map['is_active'] as int) == 1,
    );
  }

  UserModel copyWith({
    int? id,
    int? no,
    String? uid,
    String? name,
    String? mobileNumber,
    String? address,
    DateTime? createdDate,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      no: no ?? this.no,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      createdDate: createdDate ?? this.createdDate,
      isActive: isActive ?? this.isActive,
    );
  }
}

