class ApiConfig {
  static const String baseUrl = "http://192.168.3.188:5000/api";

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
  static const String broker = "192.168.3.188";
  static const int port = 1883;
  static const String clientId = "npda_client_flutter";

  //Topic 모음
  static const String mwTopic = "MW.NPDA";
  static const String npdaTopic = "NPDA.MW";
}
