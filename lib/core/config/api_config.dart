class ApiConfig {
  static const String baseUrl = "https://jsonplaceholder.typicode.com";

  //test
  static const String test = "/users";
  
  //Authentication
  static const String loginEndpoint = "/login";
  static const String logoutEndpoint = "/auth/logout";

  //Order Management
  static const String createOrderEndpoint = "/orders/create";
  static const String getOrderEndpoint = "/orders/get";
  static const String updateOrderEndpoint = "/orders/update";
  static const String deleteOrderEndpoint = "/orders/delete";
}
