import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:mc_rcon/src/exceptions.dart';
import 'package:mc_rcon/src/packet.dart';
import 'package:mc_rcon/src/util.dart';

// TODO: support multipacket response

/// Class Rcon allows to connect and send commads to a rcon sever
class Rcon {
  /// The host of [this] rcon connection.
  final String host;

  /// The port of [this] rcon connection.
  final int port;

  /// The password that [this] uses to authenticate.
  final String password;

  /// Time that [this] will wait for a response from the server before throwing [RconTimeoutException]
  final timeout;

  late Socket _socket;
  late Stream<Packet> _packetStream;
  bool _authed = false;
  int _id = 1;

  /// Wheter [this] is connected and authenticated.
  bool get authenticated => _authed;

  /// Create a new Rcon instace
  ///
  /// [host] is the ip address of the server that you want to connect to, [port] is
  /// the port (usually 25575) and [password] is the rcon password.
  /// You will need to call connect() in order to actually conect to the server
  /// and be able to perform commands
  Rcon(
    this.host,
    this.port,
    this.password, {
    this.timeout = const Duration(seconds: 10),
  });

  /// Create a new Rcon instance and connect immediatly
  ///
  /// [host], [port] and [password] are the same as in [new Rcon]
  /// You don't need to call connect() if you create the Rcon object through this method,
  /// if you call connnect it will throw and exception
  static Future<Rcon> createAndConnect(
    String host,
    int port,
    String password, {
    timeout = const Duration(seconds: 10),
  }) async {
    var rcon = Rcon(host, port, password, timeout: timeout);
    var _ = await rcon.connect();
    return rcon;
  }

  /// Connect to the rcon server
  ///
  /// This methd throws [AuthenticationFailedException] if the server password is wrong.
  /// This method throws [AlreadyConnectedException] if the [Rcon] instace is already connected
  Future<bool> connect() async {
    if (_authed) {
      throw AlreadyConnectedException();
    }

    _socket = await Socket.connect(host, port);

    var packetStreamSingle = _socket.map<Packet>((List<int> list) {
      var byteList = Uint8List.fromList(list);
      return Packet.fromUint8List(byteList);
    });

    _packetStream = turnIntoBroadcastStream<Packet>(packetStreamSingle);

    // send auth packet
    _authed = await _authenticate();
    return _authed;
  }

  /// Closes the connection with the rcon server
  ///
  /// This method throws [NotConnectedException] if the [Rcon] instace is not connected
  void disconnect() async {
    if (!_authed) {
      throw NotConnectedException();
    }

    await _socket.close();
  }

  Future<bool> _authenticate() async {
    var packetId = _id++;
    var authPacket = Packet(packetId, PacketType.AUTH, password);

    _socket.add(authPacket.bytes!);
    await _socket.flush();

    await firstWhereWithTimeout(
      _packetStream,
      timeout,
      (Packet p) {
        if (!(p.type == PacketType.AUTH_RESPONSE)) {
          return false;
        }

        if (p.id == -1) {
          throw AuthenticationFailedException();
        }

        return p.id == packetId;
      },
    );
    return true;
  }

  /// Sends a [command] to the server
  ///
  /// Then returns the respose as a [String].
  Future<String?> sendCommand(String command) async {
    if (!_authed) {
      throw NotConnectedException();
    }

    var packetId = _id++;
    var packet = Packet(packetId, PacketType.EXECCOMMAND, command);

    _socket.add(packet.bytes!);
    await _socket.flush();

    var res = await firstWhereWithTimeout(
      _packetStream,
      timeout,
      (Packet p) => p.type == PacketType.RESPONSE_VALUE && p.id == packetId,
    );

    return res.body;
  }
}
