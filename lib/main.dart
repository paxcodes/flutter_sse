import 'package:flutter/material.dart';
import 'package:sse/client/sse_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter SSE",
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final sseClient = SseClient("http://127.0.0.1:8000");

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder(
        stream: sseClient.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(snapshot.data);
          }
          return Text("");
        },
      ),
    );
  }
}
