import 'package:flutter/cupertino.dart';
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

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final http.Client _client = http.Client();

  @override
  void initState() {
    subscribe();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("[DATA HERE]"),
        SizedBox(height: 30),
        RaisedButton.icon(
          onPressed: closeConnection,
          icon: Icon(Icons.close),
          label: Text("Close the http client"),
        ),
      ],
    );
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
        streamedResponse.stream.toStringStream().listen(
          (data) {
            print("Received data: $data");
          },
          onDone: () {
            print("Done with the Stream!");
          },
          onError: (error) {
            print("ERRROR with the Stream! $error");
          },
          cancelOnError: true,
        );
      });
    } catch (e) {
      print("Caught $e");
    }
  }

  closeConnection() {
    _client.close();
    print("Closed the client! (whatever that means...)");
  }

  @override
  void dispose() {
    closeConnection();
    super.dispose();
  }
}
