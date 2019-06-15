import 'dart:typed_data';

import 'package:mc_rcon/src/exceptions.dart';
import 'package:mc_rcon/src/packet.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  group('Packet serialization', () {
    test('serialize login packet', () {
      Packet authPacket = new Packet(1, PacketType.AUTH, "password");

      expect(authPacket.bytes, equals(serializedAuthPacket));
    });

    test('serialize command packet', () {
      Packet cmdPacket = new Packet(2, PacketType.EXECCOMMAND, "list");

      expect(cmdPacket.bytes, equals(serializedCommandPacket));
    });
  });

  group('Packet deserializtion', () {
    test('deserialize auth response packet', () {
      Uint8List bytes = Uint8List.fromList(serializedAuthSuccesPacket);
      Packet authResposePacket = Packet.fromUint8List(bytes);

      expect(authResposePacket.id, equals(1));
      expect(authResposePacket.type, equals(PacketType.AUTH_RESPONSE));
      expect(authResposePacket.body, equals(""));
    });

    test('deserialize response packet', () {
      Uint8List bytes = Uint8List.fromList(serializedCmdResponsePacket);
      Packet cmdResposePacket = Packet.fromUint8List(bytes);

      expect(cmdResposePacket.id, equals(2));
      expect(cmdResposePacket.type, equals(PacketType.RESPONSE_VALUE));
      expect(cmdResposePacket.body,
          equals("There are 0 of a max 20 players online: "));
    });

    test('deserialize packet with invalid lenght', () {
      Uint8List bytes = Uint8List.fromList(invalidLengthPacket);
      expect(
        () => new Packet.fromUint8List(bytes),
        throwsA(TypeMatcher<InvalidPacketException>()),
      );
    });

    test('deserialize packet with invalid id', () {
      Uint8List bytes = Uint8List.fromList(invalidTypePacket);
      expect(
        () => new Packet.fromUint8List(bytes),
        throwsA(TypeMatcher<InvalidPacketException>()),
      );
    });
  });
}
