import 'package:customer/core/class/crud.dart';
import 'package:customer/linkApi.dart';

class ContactModel {
  ContactModel(this.crud);

  final Crud crud;

  /// جلب وسائل التواصل النشطة (يُفضّل استدعاء عام ليعمل مع أو بدون جلسة عميل).
  Future<dynamic> getContactMethods() async {
    final response = await crud.postData(
      Applink.getContactMethods,
      <String, dynamic>{},
      isPublicRoutes: true,
    );
    return response.fold((l) => l, (r) => r);
  }
}
