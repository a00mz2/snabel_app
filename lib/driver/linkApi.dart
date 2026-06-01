// ignore_for_file: constant_identifier_names

/// روابط الـ API — مواكبة مشروع الباك اند `E:\Tahouna`:
/// - `app.use(env.apiBasePath, routes)` حيث `API_BASE_PATH` الافتراضي **`/api/v1`**
/// - `routes/index.js`: `/admin`، `/customer`، `/driver`
///
/// **الإنتاج:** `https://api.snabel.app` (كما في `API_BASE_URL_LIVE` داخل `.env`).
///
/// إذا غيّر مبرمج الباك `API_BASE_PATH` على السيرفر، عدّل [apiV1Prefix] أو [host] هنا ليطابق.
class DriverApplink {
  static const String host = "https://api.snabel.app";

  /// يطابق `API_BASE_PATH` (مثلاً `/api/v1`).
  static const String apiV1Prefix = "$host/api/v1";

  /// صور المنتجات والملفات المرفوعة (`/ProductImages`، `/uploads`، …) — نفس الأصل عادة.
  static const String serverImage = "$host/";

  // --- سائق: `src/services/driver/driverRoutes.service.js` + أوامر من `Order` ---
  static const String login = "$apiV1Prefix/driver/LogInDriver";
  static const String getDriverProfile = "$apiV1Prefix/driver/getDriverProfile";
  static const String addDriverToken = "$apiV1Prefix/driver/addDriverToken";
  static const String removeDriverToken =
      "$apiV1Prefix/driver/removeDriverToken";
  static const String updateStatusOrder = "$apiV1Prefix/driver/updateStatusOrder";
  static const String driverRefreshToken = "$apiV1Prefix/driver/DriverRefreshToken";

  /// تحصيل/تسديد عبر السائق — `DriverSettlement/driverSettlementDriver.routes.js`
  static const String myDriverMediatedSettlements =
      "$apiV1Prefix/driver/myDriverMediatedSettlements";
  static const String approveDriverMediatedSettlement =
      "$apiV1Prefix/driver/approveDriverMediatedSettlement";
  static const String confirmDriverMediatedSettlement =
      "$apiV1Prefix/driver/confirmDriverMediatedSettlement";

  // --- طلبات وإشعارات: مسجّلة تحت راوتر الأدمن؛ التوكن دور `driver` مسموح في الـ handlers ---
  static const String getOrders = "$apiV1Prefix/admin/getOrders";
  static const String getNotifications = "$apiV1Prefix/admin/getNotifications";
  static const String getUnreadCount = "$apiV1Prefix/admin/getUnreadCount";

  // تطوير محلي (مثال): غيّر [host] إلى `http://10.0.2.2:1004` للمحاكي أو `localhost` حسب المنفذ في `.env`.
}
