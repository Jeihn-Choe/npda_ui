class ApiConfig {
  static const String baseUrl = "http://192.168.3.188:5000/api";

  //test
  static const String test = "/users";

  //Authentication
  static const String loginEndpoint = "/user/login";
  static const String logoutEndpoint = "/user/logout";
  static const String sessionExpiredEndpoint = "/user/expired";

  //Order Management
  static const String createOrderEndpoint = "/order/create";
  static const String deleteOrderEndpoint = "/order/delete";
}
