class ApiConfig {
  // static const String baseUrl = "http://10.2.10.180:5000/api";
  static const String baseUrl = "http://10.30.248.197/api";

  // test
  static const String test = "/users";

  // Authentication
  static const String loginEndpoint = "/auth/login";
  static const String logoutEndpoint = "/auth/logout";
  static const String sessionExpiredEndpoint = "/auth/expired";

  // Order Management
  static const String createOrderEndpoint = "/order/create";
  static const String deleteOrderEndpoint = "/order/delete";
  static const String validateOrderEndpoint = "/auth/verify-bin";

  // Robot Management
  static const String pauseRobotEndpoint = "/robot/pause";
  static const String resumeRobotEndpoint = "/robot/resume";

  // EV Management
  static const String reportEvStatusEndpoint = "/status/elevator/error";
}

class MqttConfig {
  // static const String broker = "10.2.10.180";
  static const String broker = "10.30.248.197";
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
