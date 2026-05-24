// ignore_for_file: file_names, avoid_print

Future<bool> checkAuth(int statusCode) async {
  // LoginModel loginModel = LoginModel(Get.find());

  // if (myServices.sharedPreferences.getString('refreshToken') != null) {
  //   var response = await loginModel.refreshToken();

  //   if (handlingData(response) == StatusRequest.success) {
  //     myServices.sharedPreferences.setString('Token', response["accessToken"]);
  //     print("Success RefreshToken");
  //     return true;
  //   } else {
  //     myServices.sharedPreferences.remove('Tokin');
  //     myServices.sharedPreferences.remove('route');
  //     myServices.sharedPreferences.remove('refreshToken');
  //     print("failure Tokin 1");
  //     return false;
  //   }
  // } else {
  //   myServices.sharedPreferences.remove('Tokin');
  //   myServices.sharedPreferences.remove('route');
  //   myServices.sharedPreferences.remove('refreshToken');
  //   print("failure Tokin 2");
  return false;
  // }
}
