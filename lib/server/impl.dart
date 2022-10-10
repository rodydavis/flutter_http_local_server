import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class Server {
  const Server({required this.cacheDir});

  /// The directory to use for caching files.
  final FutureOr<String> cacheDir;

  /// The URL of the local or remote server.
  Uri get url;

  /// Starts the server.
  Future<void> start();

  /// Stops the server.
  Future<void> stop();

  /// Sends a GET request to the server.
  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
  }) =>
      http.get(url.resolve(path), headers: headers);

  /// Sends a POST request to the server.
  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) =>
      http.post(
        url.resolve(path),
        headers: headers,
        body: body,
        encoding: encoding,
      );

  /// Sends a PUT request to the server.
  Future<http.Response> put(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) =>
      http.put(
        url.resolve(path),
        headers: headers,
        body: body,
        encoding: encoding,
      );
}
