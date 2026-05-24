// ignore_for_file: file_names, avoid_print

import 'package:carousel_slider/carousel_controller.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:customer/core/functions/snackbar.dart';
import 'package:customer/model/HomeModel.dart';
import 'package:customer/model/favoriteModel.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  HomeModel model = HomeModel(Get.find());
  FavoriteModel favoriteModel = FavoriteModel(Get.find());

  Rx<StatusRequest> statusRequest = StatusRequest.success.obs;
  RxInt statusCode = 200.obs;

  @override
  void onInit() {
    super.onInit();
    print("✅ staerted HomeController");
    getDataHome();
  }

  @override
  void onClose() {
    super.onClose();
    print("🧹 STOP HomeController");
  }

  //============var=================
  RxInt sliderCurrent = 0.obs;
  final CarouselSliderController slidercontroller = CarouselSliderController();

  //============Data=================
  var walletData = {}.obs;
  var listTopProducts = [].obs;
  var listallProducts = [].obs;
  var listCategories = [].obs;
  var listSliders = [].obs;

  //===============api==============

  getDataHome() async {
    statusRequest.value = StatusRequest.loading;
    var response = await model.getDataHome();
    if (handlingData(response) == StatusRequest.success) {
      try {
        walletData.value = response['wallet'];
        listTopProducts.value = response['topProducts'];
        listSliders.value = response['sliders'];
        listCategories.value = response['categories'];
        listallProducts.value = response['allProducts'];
      } catch (e) {
        print(e);
      }
    }
    statusRequest.value = handlingData(response);
    statusCode.value = handlingStatusCode(response);
  }

  toggleFavorite(String productId, bool toggle) async {
    var response = await favoriteModel.toggleFavorite(productId, toggle);
    if (handlingData(response) != StatusRequest.success) {
      final msg = tryResponseMessage(response);
      if (msg != null && msg.isNotEmpty) {
        AppSnackBar.error(msg);
      }
    }
  }

  /// توجيه السلايدر حسب [type] و [targetId] من الخادم (product/category/none).
  void openSliderAt(int index) {
    if (index < 0 || index >= listSliders.length) return;
    final raw = listSliders[index];
    if (raw is! Map) return;
    final item = Map<String, dynamic>.from(raw);
    final type = (item['type'] ?? 'none').toString().trim();
    final targetId = sliderTargetIdString(item['targetId']);
    if (type == 'none' || targetId == null || targetId.isEmpty) {
      return;
    }

    if (type == 'product') {
      Get.toNamed(
        '/ProductsDetailSecrren',
        arguments: {'productId': targetId},
      );
      return;
    }

    if (type == 'category') {
      Map<String, dynamic>? cat;
      for (final e in listCategories) {
        if (e is Map && '${e['_id']}' == targetId) {
          cat = Map<String, dynamic>.from(e);
          break;
        }
      }
      Get.toNamed(
        '/SectionProducts',
        arguments: {
          'categoryId': targetId,
          'name': cat?['name']?.toString() ?? 'القسم',
          'image': cat?['image']?.toString() ?? '',
          'sliderImage': cat?['sliderImage']?.toString() ?? '',
        },
      );
    }
  }

  /// استخراج معرف الهدف من استجابة السيرفر (نص أو ObjectId).
  static String? sliderTargetIdString(dynamic v) {
    if (v == null) return null;
    if (v is Map && v[r'$oid'] != null) {
      return v[r'$oid']?.toString();
    }
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
