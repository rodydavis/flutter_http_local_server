import 'dart:async';
import 'dart:io';

import 'impl.dart' as impl;

class Server extends impl.Server {
  late HttpServer _server;
  StreamSubscription<HttpRequest>? _subscription;
  late int _port;
  late String _host;
  late final Directory _cache;

  @override
  late Uri url;

  Server({required super.cacheDir}) {
    const envHost = String.fromEnvironment('HOST');
    const envPort = int.fromEnvironment('PORT');
    if (envHost.isNotEmpty && envPort != 0) {
      _host = envHost;
      _port = envPort;
      url = Uri.parse('http://$_host:$_port');
    } else {
      _host = InternetAddress.loopbackIPv4.address;
      _port = 8080;
      url = Uri.parse('http://$_host:$_port');
    }
  }

  late final Map<String, Function(HttpRequest)> _handlers = {
    '/': (req) {
      req.response
        ..headers.contentType = ContentType("text", "plain", charset: "utf-8")
        ..write('Hello, world')
        ..close();
    },
    '/json': (req) {
      req.response
        ..headers.contentType =
            ContentType("application", "json", charset: "utf-8")
        ..write('{"message": "Hello World!"}')
        ..close();
    },
    '/create-log-file': (req) {
      // Create really long log file
      final file = File('${_cache.path}/log.txt');
      if (!file.existsSync()) {
        final sink = file.openWrite();
        for (var i = 0; i < 100000; i++) {
          sink.writeln('This is line $i');
        }
        sink.close();
      }
      req.response
        ..headers.contentType = ContentType("text", "plain", charset: "utf-8")
        ..statusCode = HttpStatus.ok
        ..write('Created log file')
        ..close();
    },
    '/read-log-file': (req) {
      final file = File('${_cache.path}/log.txt');
      if (file.existsSync()) {
        req.response
          ..headers.contentType = ContentType("text", "plain", charset: "utf-8")
          ..statusCode = HttpStatus.ok
          ..write(file.readAsStringSync())
          ..close();
      } else {
        req.response
          ..headers.contentType = ContentType("text", "plain", charset: "utf-8")
          ..statusCode = HttpStatus.notFound
          ..write('Log file not found')
          ..close();
      }
    },
  };

  Future<void> _handle(HttpRequest req) async {
    final handler = _handlers[req.uri.path];
    _cors(req);
    if (handler != null) {
      handler(req);
    } else {
      req.response
        ..statusCode = HttpStatus.notFound
        ..close();
    }
  }

  void _cors(HttpRequest req) {
    req.response.headers.add(
      'Access-Control-Allow-Origin',
      '*',
    );
    req.response.headers.add(
      'Access-Control-Allow-Methods',
      'GET, POST, PUT',
    );
    req.response.headers.add(
      'Access-Control-Allow-Headers',
      'Origin, X-Requested-With, Content-Type, Accept',
    );
  }

  @override
  Future<void> start() async {
    _server = await HttpServer.bind(_host, _port);
    // _server.autoCompress = true;
    _cache = Directory(await cacheDir);
    if (!_cache.existsSync()) _cache.createSync(recursive: true);
    _subscription = _server.listen(_handle);
  }

  @override
  Future<void> stop() async {
    await _subscription?.cancel();
    await _server.close();
  }
}
