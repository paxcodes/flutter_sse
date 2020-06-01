import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  final http.Client _client = http.Client();

  MyHomePage() {
    subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("[DATA HERE]"));
  }

  subscribe() async {
    print("Subscribing...");
    try {
      var request =
          new http.Request("GET", Uri.parse("http://localhost:8000/sse"));
      request.headers["Cache-Control"] = "no-cache";
      request.headers["Accept"] = "text/event-stream";

      Future<http.StreamedResponse> response = _client.send(request);
      response.asStream().listen((streamedResponse) {
        print(
            "Received streamedResponse.statusCode:${streamedResponse.statusCode}");
        streamedResponse.stream.listen((data) {
          print("Received data: $data");
        });
      });
    } catch (e) {
      print("Caught $e");
    }
  }
}
