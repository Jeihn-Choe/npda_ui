class ApiConfig {
  static const String baseUrl = "http://10.126.208.92:5000/api";

  // test
  static const String test = "/users";

  // Authentication
  static const String loginEndpoint = "/user/login";
  static const String logoutEndpoint = "/user/logout";
  static const String sessionExpiredEndpoint = "/user/expired";

  // Order Management
  static const String createOrderEndpoint = "/order/create";
  static const String deleteOrderEndpoint = "/order/delete";

  // Robot Management
  // pause & resume 필요
}

class MqttConfig {
  static const String broker = "10.30.248.205";
  static const int port = 1883;
  static const String clientId = "npda_client_flutter";

  //Topic 모음
  static const String mwTopic = "MW.NPDA";
  static const String npdaTopic = "NPDA.MW";
}
