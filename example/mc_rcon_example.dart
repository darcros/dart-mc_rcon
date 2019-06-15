import 'package:mc_rcon/mc_rcon.dart';

main() async {
  Rcon rcon;
  try {
    // connect to the Minecraft server
    rcon = await Rcon.createAndConnect("localhost", 25575, "password");
  } on AuthenticationFailedException {
    print("wrong password");
  }

  // send "/help" command and print result
  String res = await rcon.sendCommand("help");
  print(res);

  // close connection
  rcon.disconnect();
}
