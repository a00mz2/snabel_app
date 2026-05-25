import '../class/statusRequest.dart';
import 'package:dartz/dartz.dart';

StatusRequest handlingData(dynamic response) {
  if (response is Either<StatusRequest, Map>) {
    return response.fold(
      (failure) => failure,
      (data) => data.containsKey("statusRequest")
          ? data["statusRequest"] as StatusRequest
          : StatusRequest.success,
    );
  }
  if (response is StatusRequest) {
    return response;
  }
  if (response is Map) {
    final sr = response["statusRequest"];
    if (sr is StatusRequest) return sr;
    return StatusRequest.failure;
  }
  return StatusRequest.failure;
}

int handlingStatusCode(dynamic response) {
  if (handlingData(response) == StatusRequest.success) {
    return 200;
  }
  if (response is Map) {
    final code = response['statusCode'];
    if (code is int) return code;
    if (code is num) return code.toInt();
  }
  return 404;
}

/// رسالة من الـ API عند توفرها (نجاح أو فشل بجسم JSON).
String apiMessageFromMap(dynamic response, [String fallback = '']) {
  if (response is Map) {
    final m = response['message'];
    if (m != null && m.toString().isNotEmpty) return m.toString();
  }
  return fallback;
}

/// رسالة خطأ للمستخدم عند فشل الطلب أو عدم وجود [message] في الرد.
String apiErrorMessage(dynamic response, [String fallback = 'حدث خطأ']) {
  final fromApi = apiMessageFromMap(response, '');
  if (fromApi.isNotEmpty) return fromApi;
  if (response is StatusRequest) {
    switch (response) {
      case StatusRequest.offlineFailure:
        return 'لا يوجد اتصال بالإنترنت';
      case StatusRequest.serverFailure:
        return 'تعذر الاتصال بالخادم';
      case StatusRequest.failureTokin:
        return 'انتهت الجلسة، يرجى تسجيل الدخول مجدداً';
      case StatusRequest.failure:
        return fallback;
      default:
        return fallback;
    }
  }
  return fallback;
}
