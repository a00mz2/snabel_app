import 'package:customer/core/class/crud.dart';
import 'package:customer/linkApi.dart';

/// طبقة API للتحقق العكسي.
///  start  → يبدأ جلسة ويعيد { ref, code, waLink, serviceNumber, expiresAt }
///  status → يستعلم بالـ ref ويعيد { verified, status }
class ReverseVerifyModel {
  ReverseVerifyModel(this.crud);
  final Crud crud;

  Future<dynamic> start(String phone, String purpose) async {
    final response = await crud.postData(
      Applink.reverseStart,
      {"phone": phone, "purpose": purpose},
      isRetry: false,
      isPublicRoutes: true,
    );
    return response.fold((failure) => failure, (data) => data);
  }

  Future<dynamic> status(String ref) async {
    final response = await crud.postData(
      Applink.reverseStatus,
      {"ref": ref},
      isRetry: false,
      isPublicRoutes: true,
    );
    return response.fold((failure) => failure, (data) => data);
  }
}
