import 'dart:convert';
import 'dart:typed_data';

import 'package:mc_rcon/src/exceptions.dart';

enum Direction {
  SERVERBOUND,
  CLIENTBOUND,
}

// Has to use a class because enums don't support values
class PacketType {
  final _value;
  const PacketType._internal(this._value);
  int get value => _value;
  String toString() => _value.toString();

  static fromValue(int n, [Direction direction = Direction.CLIENTBOUND]) {
    switch (n) {
      case 0:
        return PacketType.RESPONSE_VALUE;

      case 2:
        if (direction == Direction.CLIENTBOUND) {
          return PacketType.AUTH_RESPONSE;
        } else {
          return PacketType.EXECCOMMAND;
        }
        break;

      case 3:
        return PacketType.AUTH;

      default:
        return null;
    }
  }

  static const RESPONSE_VALUE = const PacketType._internal(0);
  static const EXECCOMMAND = const PacketType._internal(2);
  static const AUTH_RESPONSE = const PacketType._internal(2);
  static const AUTH = const PacketType._internal(3);
}

class Packet {
  int _id;
  PacketType _type;
  String _body;
  Uint8List _bytes;

  int get id => _id;
  PacketType get type => _type;
  String get body => _body;
  Uint8List get bytes => _bytes;

  Packet(int id, PacketType type, String body)
      : _id = id,
        _type = type,
        _body = body,
        _bytes = _encodePacket(type, id, body);

  static Uint8List _encodePacket(PacketType type, int id, String body) {
    Uint8List bodyByteList = utf8.encode(body);

    int size = bodyByteList.lengthInBytes + 14;
    ByteData bytes = new ByteData(size);

    bytes.setInt32(0, size - 4, Endian.little);
    bytes.setInt32(4, id, Endian.little);
    bytes.setInt32(8, type.value, Endian.little);

    int i = 0;
    for (var offs = 12; offs < size - 2; offs++) {
      bytes.setUint8(offs, bodyByteList[i]);
      i++;
    }

    bytes.setInt16(size - 2, 0);

    return bytes.buffer.asUint8List();
  }

  Packet.fromUint8List(Uint8List byteList) {
    _bytes = byteList;
    ByteData bytes = byteList.buffer.asByteData();

    int size = bytes.getInt32(0, Endian.little);
    if (size != bytes.lengthInBytes - 4) {
      throw new InvalidPacketException(
          "invalid packet lenght: expected ${bytes.lengthInBytes - 4} found: $size");
    }

    _id = bytes.getInt32(4, Endian.little);

    int intType = bytes.getInt32(8, Endian.little);
    _type = PacketType.fromValue(intType);
    if (_type == null) {
      throw new InvalidPacketException("invalid type $intType");
    }

    int bodyLength = byteList.lengthInBytes - 14;
    Uint8List bodyBytes = new Uint8List(bodyLength);
    bodyBytes.setRange(0, bodyLength, byteList, 12);

    _body = utf8.decode(bodyBytes);
  }
}
