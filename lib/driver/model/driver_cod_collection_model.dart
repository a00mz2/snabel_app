import 'package:customer/driver/core/class/crud.dart';
import 'package:customer/driver/linkApi.dart';

/// مبالغ «الدفع عند الاستلام» الخاصة بالسائق الحالي.
/// الخادم يأخذ معرّف السائق من التوكن — لا يُرسَل من التطبيق.
class DriverCodCollectionModel {
  final DriverCrud crud;

  DriverCodCollectionModel(this.crud);

  /// [status]: `outstanding` (في ذمتي) أو `settled` (تم التسديد) أو `all`.
  Future<dynamic> myCodCollections({
    int page = 1,
    int limit = 50,
    String status = 'outstanding',
  }) async {
    final uri = Uri.parse(DriverApplink.myCodCollections).replace(
      queryParameters: {'page': '$page', 'limit': '$limit', 'status': status},
    );
    final response = await crud.request(
      method: 'GET',
      url: uri.toString(),
      data: null,
    );
    return response.fold((l) => l, (r) => r);
  }
}
