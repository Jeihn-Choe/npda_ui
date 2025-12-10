class ApiConfig {
  static const String baseUrl = "http://10.30.248.145:5000/api";

  // test
  static const String test = "/users";

  // Authentication
  static const String loginEndpoint = "/user/login";
  static const String logoutEndpoint = "/user/logout";
  static const String sessionExpiredEndpoint = "/user/expired";

  // Order Management
  static const String createOrderEndpoint = "/order/create";
  static const String deleteOrderEndpoint = "/order/delete";
  static const String validateOrderEndpoint = "/order/validate";

  // Robot Management
  // pause & resume 필요
}

class MqttConfig {
  static const String broker = "192.168.3.115";
  static const int port = 1883;
  static const String clientId = "npda_client";

  //Topic 모음
  static const String mwTopic = "MW.NPDA";
  static const String npdaTopic = "NPDA.MW";

  // 로봇 상태 토픽
  static const String ssrStatusTopic = "mid.sol/8100";
  static const String spt1FStatusTopic = "mid.sol/8101";
  static const String spt3FStatusTopic = "mid.sol/8102";
}
