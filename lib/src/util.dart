// ignore_for_file: unnecessary_new

import 'dart:async';

import 'package:mc_rcon/src/exceptions.dart';

Stream<T> turnIntoBroadcastStream<T>(Stream<T> s) {
  var controller = StreamController<T>.broadcast();

  s.listen(
    (data) => controller.add(data),
    onDone: () => controller.close(),
    onError: (err) => controller.addError(err),
  );

  return controller.stream;
}

Future<T> firstWhereWithTimeout<T>(
  Stream<T> stream,
  Duration timeout,
  bool Function(T element) test,
) async {
  var timer = new Timer(timeout, () => throw new TimeoutException());

  var found = await stream.firstWhere(test);

  timer.cancel();
  return found;
}
