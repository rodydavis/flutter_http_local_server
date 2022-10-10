import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'server/server.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Local Server',
      theme: ThemeData.dark(),
      home: const Example(),
    );
  }
}

class Example extends StatefulWidget {
  const Example({Key? key}) : super(key: key);

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  bool loading = false;
  Server? server;
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cache = getApplicationDocumentsDirectory()
        .then((dir) => '${dir.path}/cache')
        .catchError((_) => '.cache');
    server = Server(cacheDir: cache);
    server!.start().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    server?.stop();
  }

  void requestData() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    await server!.post('/create-log-file');
    final response = await server!.get('/read-log-file');
    if (mounted) {
      setState(() {
        controller.text = response.body;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Local Server'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Server started at ${server?.url}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: requestData,
              child: const Text('Request Data'),
            ),
            const SizedBox(height: 16),
            if (loading) const LinearProgressIndicator(),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Response',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
