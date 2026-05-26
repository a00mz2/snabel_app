import 'package:customer/driver/core/class/crud.dart';
import 'package:customer/driver/linkApi.dart';

class DriverSettlementModel {
  final DriverCrud crud;

  DriverSettlementModel(this.crud);

  Future<dynamic> mySettlements({
    int page = 1,
    int limit = 20,
    String status = 'all',
  }) async {
    final uri = Uri.parse(DriverApplink.myDriverMediatedSettlements).replace(
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
        'status': status,
      },
    );
    final response = await crud.request(
      method: 'GET',
      url: uri.toString(),
      data: null,
    );
    return response.fold((l) => l, (r) => r);
  }

  /// الباك اند يستخدم `multer().none()` — الحقول تُقرأ من multipart وليس من JSON.
  Future<dynamic> approve(String requestId) async {
    final response = await crud.request(
      method: 'MULTIPART',
      url: DriverApplink.approveDriverMediatedSettlement,
      data: {'requestId': requestId},
      files: {},
      methodMultipart: 'POST',
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> confirm(String requestId) async {
    final response = await crud.request(
      method: 'MULTIPART',
      url: DriverApplink.confirmDriverMediatedSettlement,
      data: {'requestId': requestId},
      files: {},
      methodMultipart: 'POST',
    );
    return response.fold((l) => l, (r) => r);
  }
}
