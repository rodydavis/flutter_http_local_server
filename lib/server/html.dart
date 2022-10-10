import 'package:flutter/foundation.dart';

import 'impl.dart' as impl;

class Server extends impl.Server {
  Server({required super.cacheDir});

  @override
  Future<void> start() async {
    // No-op
  }

  @override
  Future<void> stop() async {
    // No-op
  }

  @override
  Uri get url => Uri.parse(kReleaseMode
      // TODO: URL should be Cloud Run URL when deployed
      ? 'http://127.0.0.1:8000'
      : 'http://127.0.0.1:8000');
}
