import '../class/statusRequest.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:dartz/dartz.dart';

StatusRequest handlingData(dynamic response) {
  if (response is Either<StatusRequest, Map>) {
    // إذا كانت Either
    return response.fold(
      (failure) => failure, // Left -> فشل
      (data) => data.containsKey("statusRequest")
          ? data["statusRequest"] as StatusRequest
          : StatusRequest.success,
    );
  } else if (response is StatusRequest) {
    // إذا كانت مباشرة StatusRequest
    return response;
  } else if (response is Map && response.containsKey("statusRequest")) {
    // إذا كانت Map مباشرة
    return response["statusRequest"] as StatusRequest;
  } else {
    return StatusRequest.success;
  }
}

int handlingStatusCode(dynamic response) {
  if (handlingData(response) == StatusRequest.success) {
    return 200;
  }
  final m = tryResponseMap(response);
  if (m != null && m.containsKey('statusCode')) {
    final c = m['statusCode'];
    if (c is int) return c;
    if (c is num) return c.toInt();
  }
  return 404;
}
