# mc_rcon

A library for sending commands to Minecraft servers using the rcon protocol.

This package has only been tested with Minecraft servers, so it might not work with any other game server, PRs are welcome.

Also, this package doesn't support multi-packet responses from the server, the other packets will just be ignored.

## Usage

A simple usage example:

```dart
import 'package:mc_rcon/mc_rcon.dart';

main() {
  // connect to server
  Rcon rcon = await Rcon.createAndConnect("localhost", 25575, "password");
  
  // send command
  String res = await rcon.sendCommand("help");
  print(res);

  // close connection
  rcon.disconnect();
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/7ixi0/dart-mc_rcon/issues
