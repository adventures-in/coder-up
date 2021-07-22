import 'package:coder_up/web_socket_service.dart';
import 'package:flutter/material.dart';

final service = WebSocketService();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _words = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coder Up'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: StreamBuilder(
                    stream: service.stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasError && snapshot.hasData) {
                        _words.add(snapshot.data! as String);
                      }
                      return Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: 'Hello '),
                            const TextSpan(
                              text: 'bold',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: ' world!'),
                            for (var word in _words) TextSpan(text: ' $word'),
                          ],
                        ),
                      );
                    }),
              ),
            ),
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a search term'),
              onSubmitted: (value) => service.publish(value),
            )
          ],
        ),
      ),
    );
  }
}
