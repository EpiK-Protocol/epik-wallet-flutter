class ServerConfig {
  /// "https://explorer.epik-protocol.io/api/",
  String WalletAPI;

  /// "wss://ropsten.infura.io/ws/v3/1bbd25bd3af94ca2b294f93c346f69cd",
  String ETHAPI;

  /// "ws://18.181.234.52:1234/rpc/v0",
  String EPKAPI;

  /// "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBbGxvdyI6WyJyZWFkIiwid3JpdGUiXX0.6lL7ayYWfLqEh0BqOtCwUvLVEJ5LJ1BMb3HFRRaHsVY"
  String EPKToken;

  ServerConfig.fromJson(Map<String, dynamic> json) {
    try {
      WalletAPI = json["WalletAPI"];
      ETHAPI = json["ETHAPI"];
      EPKAPI = json["EPKAPI"];
      EPKToken = json["EPKToken"];
    } catch (e) {
      print("ServerConfig.fromJson error");
      print(e);
    }
  }
}
