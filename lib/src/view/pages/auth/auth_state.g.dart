// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthState _$AuthStateFromJson(Map<String, dynamic> json) => _AuthState(
  isLoading: json['isLoading'] as bool? ?? false,
  isSignedIn: json['isSignedIn'] as bool? ?? false,
  userId: json['userId'] as String?,
  displayName: json['displayName'] as String?,
  email: json['email'] as String?,
  errorMessage: json['errorMessage'] as String?,
);

Map<String, dynamic> _$AuthStateToJson(_AuthState instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'isSignedIn': instance.isSignedIn,
      'userId': instance.userId,
      'displayName': instance.displayName,
      'email': instance.email,
      'errorMessage': instance.errorMessage,
    };
