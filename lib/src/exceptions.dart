/// Thrown when the authentication fails
/// 
/// This exception gets thrown then the server refuses to authenticate the client,
/// likely because the password is wrong.
class AuthenticationFailedException implements Exception {
  AuthenticationFailedException();

  String toString() => "AuthenticationFailedException";
}

/// Thrown when trying to do something without connecting first
///
/// This exception gets thrown when trying to perform an action
/// that requires to be connected to the rcon server without having
/// connected first, for example sending a command or disconnecting.
class NotConnectedException implements Exception {
  NotConnectedException();

  String toString() => "NotConnectedException";
}

/// Thrown then calling connect() but the Rcon instance is already connected
class AlreadyConnectedException implements Exception {
  AlreadyConnectedException();

  String toString() => "AlreadyConnectedException";
}

/// Thrown when the rcon server fails to respond within the timeout duration
class TimeoutException implements Exception {
  TimeoutException();

  String toString() => "TimeoutException";
}

/// Thrown when trying to deserialize an invalid packet
class InvalidPacketException implements Exception {
  final String reason;
  InvalidPacketException(this.reason);

  String toString() => "InvalidPacketException: $reason";
}
