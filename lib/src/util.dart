import 'dart:async';

import 'package:mc_rcon/src/exceptions.dart';

Stream<T> turnIntoBroadcastStream<T>(Stream<T> s) {
  StreamController<T> controller = new StreamController.broadcast();

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
  bool test(T element),
) async {
  Timer timer = new Timer(timeout, () => throw new TimeoutException());

  T found = await stream.firstWhere(test);

  timer.cancel();
  return found;
}
