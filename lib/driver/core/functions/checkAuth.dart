// ignore_for_file: file_names

/// التحقق من نجاح الطلب بحسب رمز HTTP.
/// تجديد التوكن يتم تلقائياً داخل [DriverCrud] عند 401/403.
Future<bool> checkAuth(int statusCode) async {
  return statusCode >= 200 && statusCode < 300;
}
