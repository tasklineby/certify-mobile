// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_request_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$LoginRequestDtoToJson(LoginRequestDto instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

Map<String, dynamic> _$RegisterRequestDtoToJson(RegisterRequestDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'company_id': instance.companyId,
    };

Map<String, dynamic> _$RefreshTokenDtoToJson(RefreshTokenDto instance) =>
    <String, dynamic>{'refresh_token': instance.refreshToken};

Map<String, dynamic> _$LogoutRequestDtoToJson(LogoutRequestDto instance) =>
    <String, dynamic>{'refresh_token': instance.refreshToken};
