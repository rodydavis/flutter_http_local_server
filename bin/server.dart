import 'package:flutter_http_local_server/server/server.dart';

Future<void> main() async {
  final server = Server(cacheDir: Future.value('.cache'));
  try {
    await server.start();
    // ignore: avoid_print
    print('Server started at ${server.url}');
  } catch (e) {
    // ignore: avoid_print
    print('Server failed to start: $e');
    await server.stop();
  }
}
