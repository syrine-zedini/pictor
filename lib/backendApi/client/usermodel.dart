
import 'dart:convert'; // Peut être nécessaire si User.fromJson/toJson utilise jsonDecode/jsonEncode ici

class User {
  final String userId;
  final String userName;
  final String nomPrenom;
  final String? password;
  final String email;
  final String? phoneNumber;
  final bool isActive;
  final String? idRole;
  final String? token;
  final String? resetPasswordTokenId;
  final DateTime? resetPasswordTokenExpiration;
  final bool? resetPasswordTokenUsed;
  final String? pathImg;
  final String? role;
  final DateTime? dateCreation;
  final DateTime? dateUpdated;
  final String? clientId;
  final String? client;

  User({
    required this.userId,
    required this.userName,
    required this.nomPrenom,
    this.password,
    required this.email,
    this.phoneNumber,
    required this.isActive,
    this.idRole,
    this.token,
    this.resetPasswordTokenId,
    this.resetPasswordTokenExpiration,
    this.resetPasswordTokenUsed,
    this.pathImg,
    this.role,
    this.dateCreation,
    this.dateUpdated,
    this.clientId,
    this.client,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      nomPrenom: json['nomPrenom'] as String,
      password: json['password'] as String?,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      isActive: json['isActive'] as bool,
      idRole: json['idRole'] as String?,
      token: json['token'] as String?,
      resetPasswordTokenId: json['resetPasswordTokenId'] as String?,
      resetPasswordTokenExpiration: json['resetPasswordTokenExpiration'] != null
          ? DateTime.parse(json['resetPasswordTokenExpiration'])
          : null,
      resetPasswordTokenUsed: json['resetPasswordTokenUsed'] as bool?,
      pathImg: json['pathImg'] as String?,
      role: json['role'] as String?,
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'])
          : null,
      dateUpdated: json['dateUpdated'] != null
          ? DateTime.parse(json['dateUpdated'])
          : null,
      clientId: json['clientId'] as String?,
      client: json['client'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'nomPrenom': nomPrenom,
      'password': password,
      'email': email,
      'phoneNumber': phoneNumber,
      'isActive': isActive,
      'idRole': idRole,
      'token': token,
      'resetPasswordTokenId': resetPasswordTokenId,
      'resetPasswordTokenExpiration': resetPasswordTokenExpiration?.toIso8601String(),
      'resetPasswordTokenUsed': resetPasswordTokenUsed,
      'pathImg': pathImg,
      'role': role,
      'dateCreation': dateCreation?.toIso8601String(),
      'dateUpdated': dateUpdated?.toIso8601String(),
      'clientId': clientId,
      'client': client,
    };
  }
}