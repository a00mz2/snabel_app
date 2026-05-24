// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:customer/core/services/services.dart';

class Applink {
  static const String _defaultHost = "https://api.snabel.app/";

  static String get host {
    try {
      final s = myServices.sharedPreferences.getString('server');
      if (s != null && s.isNotEmpty) {
        var h = s.trim();
        if (!h.endsWith('/')) h = '$h/';
        return h;
      }
    } catch (_) {}
    return _defaultHost;
  }

  static String get apiBasePath => "${host}api/v1/";
  static String get adminServer => "${apiBasePath}admin/";
  static String get customerServer => "${apiBasePath}customer/";
  static String get driverServer => "${apiBasePath}driver/";
  static String get serverImage => host;

  static String get hostNoSlash {
    final h = host;
    return h.endsWith("/") ? h.substring(0, h.length - 1) : h;
  }

  static String get uploadsBase => "$hostNoSlash/public/uploads";

  static String imageUrl(
    String? value, {
    String? bucket,
  }) {
    if (value == null || value.trim().isEmpty) return "";

    final raw = value.trim();

    if (raw.startsWith("http://") || raw.startsWith("https://")) {
      return raw;
    }

    final normalized = raw.startsWith("/") ? raw.substring(1) : raw;

    if (normalized.startsWith("public/uploads/")) {
      return "$hostNoSlash/$normalized";
    }
    if (normalized.startsWith("uploads/")) {
      return "$hostNoSlash/$normalized";
    }

    final normalizedLower = normalized.toLowerCase();
    if (normalizedLower.startsWith("customersimages/")) {
      return "$uploadsBase/customers/${normalized.substring("customersimages/".length)}";
    }
    if (normalizedLower.startsWith("productimages/")) {
      return "$uploadsBase/products/${normalized.substring("productimages/".length)}";
    }
    if (normalizedLower.startsWith("categoryimages/")) {
      return "$uploadsBase/categories/${normalized.substring("categoryimages/".length)}";
    }
    if (normalizedLower.startsWith("sliderimages/")) {
      return "$uploadsBase/slider/${normalized.substring("sliderimages/".length)}";
    }

    if (normalized.contains("/")) {
      return "$uploadsBase/$normalized";
    }

    if (bucket != null && bucket.isNotEmpty) {
      return "$uploadsBase/$bucket/$normalized";
    }

    return "$uploadsBase/$normalized";
  }

  static String customerImage(String? value) =>
      imageUrl(value, bucket: "customers");
  static String driverImage(String? value) =>
      imageUrl(value, bucket: "drivers");
  static String adminImage(String? value) => imageUrl(value, bucket: "admins");
  static String productImage(String? value) =>
      imageUrl(value, bucket: "products");
  static String categoryImage(String? value) =>
      imageUrl(value, bucket: "categories");
  static String sliderImage(String? value) =>
      imageUrl(value, bucket: "slider");

  static String get login => "${customerServer}LogInCustomer";
  static String get createOtp => "${customerServer}createOtp";

  /// نسيت كلمة المرور (بدون توكن)
  static String get requestForgotPasswordOtp =>
      "${customerServer}requestForgotPasswordOtp";
  static String get resetPasswordWithOtp =>
      "${customerServer}resetPasswordWithOtp";
  /// بديل متوافق مع الخادم
  static String get completeForgotPasswordWithOtp =>
      "${customerServer}completeForgotPasswordWithOtp";

  /// تغيير كلمة المرور من الإعدادات (يتطلب توكن عميل)
  static String get requestPasswordChangeOtp =>
      "${customerServer}requestPasswordChangeOtp";
  static String get confirmPasswordChangeWithOtp =>
      "${customerServer}confirmPasswordChangeWithOtp";
  static String get addToken => "${customerServer}addToken";
  static String get removeToken => "${customerServer}removeToken";
  static String get toggleFavorite => "${customerServer}toggleFavorite";
  static String get getFavorites => "${customerServer}getFavorites";
  static String get getNotifications => "${adminServer}getNotifications";
  static String get getUnreadCount => "${adminServer}getUnreadCount";
  static String get createCustomer => "${customerServer}createCustomer";
  static String get getDataCustomer => "${customerServer}getDataCustomer";
  static String get CustomersRefreshToken =>
      "${customerServer}CustomersRefreshToken";
  static String get GetDataHome => "${customerServer}GetDataHome";
  static String get getProducts => "${adminServer}getProducts";
  static String get getCategories => "${adminServer}getCategories";
  static String get addToCart => "${customerServer}addToCart";
  static String get updateCartQuantity => "${customerServer}updateCartQuantity";
  static String get createPinnedOrder => "${adminServer}createPinnedOrder";
  static String get removeFromCart => "${customerServer}removeFromCart";
  static String get getCart => "${customerServer}getCart";
  static String get getDeliveryPeriods => "${adminServer}getDeliveryPeriods";
  static String get createOrderFromCart =>
      "${customerServer}createOrderFromCart";
  static String get getOrders => "${adminServer}getOrders";
  static String get getTransactions => "${adminServer}getTransactions";
  static String get updateCustomer => "${customerServer}updateCustomer";
  static String get softDeleteMyAccount => "${customerServer}softDeleteMyAccount";

  /// طلبات مثبتة — واجهة العميل (POST + JSON)
  static String get listMyPinnedOrders => "${customerServer}listMyPinnedOrders";
  static String get getMyPinnedOrder => "${customerServer}getMyPinnedOrder";
  static String get updateMyPinnedOrder => "${customerServer}updateMyPinnedOrder";
  static String get deleteMyPinnedOrder => "${customerServer}deleteMyPinnedOrder";

  /// وسائل التواصل (عامة — بدون توكن إداري)
  static String get getContactMethods => "${customerServer}getContactMethods";

  /// الخصوصية والشروط (صفحة HTML على نفس نطاق الـ API)
  static String get privacyPolicyUrl => '$hostNoSlash/privacy-terms.html';
}
