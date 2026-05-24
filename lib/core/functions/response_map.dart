import 'package:customer/core/class/statusRequest.dart';
import 'package:dartz/dartz.dart';

/// يستخرج [Map] من نتيجة الـ API عندما تكون [Either] أو [Map]، وإلا يعيد null.
Map<String, dynamic>? tryResponseMap(dynamic response) {
  if (response is Map<String, dynamic>) return response;
  if (response is Map) return Map<String, dynamic>.from(response);
  if (response is Either<StatusRequest, Map>) {
    return response.fold(
      (_) => null,
      (m) => Map<String, dynamic>.from(m),
    );
  }
  return null;
}

String? tryResponseMessage(dynamic response) {
  final m = tryResponseMap(response);
  final v = m?['message'];
  if (v == null) return null;
  return v.toString();
}
