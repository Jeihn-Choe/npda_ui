class ApiConfig {
  static const String baseUrl = "https://api.example.com";

  //Authentication
  static const String loginEndpoint = "/auth/login";
  static const String logoutEndpoint = "/auth/logout";

  //Order Management
  static const String createOrderEndpoint = "/orders/create";
  static const String getOrderEndpoint = "/orders/get";
  static const String updateOrderEndpoint = "/orders/update";
  static const String deleteOrderEndpoint = "/orders/delete";
}
