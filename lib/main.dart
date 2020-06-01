import 'dart:async';

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
  Future<http.StreamedResponse> streamedResponseFuture;

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
        FutureBuilder<http.StreamedResponse>(
          future: streamedResponseFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              http.StreamedResponse streamedResponse = snapshot.data;
              return StreamBuilder<String>(
                  stream: streamedResponse.stream.toStringStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('No data yet.');
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      return Text('Done!');
                    } else if (snapshot.hasError) {
                      return Text('Error!');
                    } else if (snapshot.hasData) {
                      print(snapshot.data);
                      return Text(snapshot.data);
                    }
                    return Text("No IDEA what's going on.");
                  });
            }
            return CircularProgressIndicator();
          },
        ),
        SizedBox(height: 30),
        RaisedButton.icon(
          onPressed: closeClient,
          icon: Icon(Icons.close),
          label: Text("Close the http client"),
        ),
      ],
    );
  }

  subscribe() async {
    print("Subscribing...");
    try {
      http.Request request =
          http.Request("GET", Uri.parse("http://localhost:8000/sse"));
      request.headers["Cache-Control"] = "no-cache";
      request.headers["Accept"] = "text/event-stream";

      streamedResponseFuture = _client.send(request);
    } catch (e) {
      print("Caught $e");
    }
  }

  closeClient() {
    _client.close();
    print("Closed the client!");
  }

  @override
  void dispose() {
    closeClient();
    super.dispose();
  }
}
