import 'package:json_annotation/json_annotation.dart';

part 'auth_request_models.g.dart';

@JsonSerializable(createFactory: false, fieldRename: FieldRename.snake)
class LoginRequestDto {
  final String email;
  final String password;

  const LoginRequestDto({required this.email, required this.password});

  Map<String, dynamic> toJson() => _$LoginRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false, fieldRename: FieldRename.snake)
class RegisterRequestDto {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final int companyId;

  const RegisterRequestDto({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.companyId,
  });

  Map<String, dynamic> toJson() => _$RegisterRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false, fieldRename: FieldRename.snake)
class RefreshTokenDto {
  final String refreshToken;

  const RefreshTokenDto({required this.refreshToken});

  Map<String, dynamic> toJson() => _$RefreshTokenDtoToJson(this);
}

@JsonSerializable(createFactory: false, fieldRename: FieldRename.snake)
class LogoutRequestDto {
  final String refreshToken;

  const LogoutRequestDto({required this.refreshToken});

  Map<String, dynamic> toJson() => _$LogoutRequestDtoToJson(this);
}
