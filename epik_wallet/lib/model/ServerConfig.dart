class ServerConfig {
  /// "https://explorer.epik-protocol.io/api/",
  String WalletAPI;

  /// "wss://ropsten.infura.io/ws/v3/1bbd25bd3af94ca2b294f93c346f69cd",
  String ETHAPI;

  /// "ws://18.181.234.52:1234/rpc/v0",
  String EPKAPI;

  /// "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBbGxvdyI6WyJyZWFkIiwid3JpdGUiXX0.6lL7ayYWfLqEh0BqOtCwUvLVEJ5LJ1BMb3HFRRaHsVY"
  String EPKToken;

  /// Sigrid_EpiK
  String SignWeixin;
  /// https://t.me/EpikProtocol
  String SignTele;

  String EPKNetwork;

  ServerConfig.fromJson(Map<String, dynamic> json) {
    try {
      WalletAPI = json["WalletAPI"];
      ETHAPI = json["ETHAPI"];
      EPKAPI = json["EPKAPI"];
      EPKToken = json["EPKToken"];
      SignWeixin = json["SignWeixin"];
      SignTele = json["SignTele"];
      EPKNetwork = json["EPKNetwork"]??"";

      //TODO TEST
      // EPKAPI = "ws://116.63.146.223:1234/rpc/v0";
      // EPKToken="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBbGxvdyI6WyJyZWFkIiwid3JpdGUiLCJzaWduIiwiYWRtaW4iXX0.AO1oyT-WtXCMDH4FW-1v3mnvGFR6-zqz4O2VdnfKboQ";
    } catch (e) {
      print("ServerConfig.fromJson error");
      print(e);
    }
  }
}
