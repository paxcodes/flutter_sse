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
//  StreamSubscription fibonacciStreamSubscription;
  bool isStreamPaused = false;

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
        SizedBox(height: 30),
        RaisedButton.icon(
          onPressed: isStreamPaused ? resumeStream : pauseStream,
          icon: Icon(isStreamPaused ? Icons.play_arrow : Icons.pause),
          label: Text("${isStreamPaused ? "Play" : "Pause"} the stream"),
        ),
        SizedBox(height: 30),
        RaisedButton.icon(
          onPressed: cancelStream,
          icon: Icon(Icons.stop),
          label: Text("Stop the stream"),
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

      streamedResponseFuture = _client.send(request);
//      print("Received streamedResponse.statusCode:${response.statusCode}");
//      fibonacciStream.asyncExpand((event) => null)
//      fibonacciStream.cast(response.stream.toStringStream());
//        fibonacciStreamSubscription =
//            streamedResponse.stream.toStringStream().listen(
//          (data) {
//            print("Received data: $data");
//          },
//          onDone: () {
//            print("Done with the Stream!");
//          },
//          onError: (error) {
//            print("ERRROR with the Stream! $error");
//          },
//          cancelOnError: true,
//        );
//      });
    } catch (e) {
      print("Caught $e");
    }
  }

  closeClient() {
    _client.close();
    // TODO what does it mean to close the client?
    print("Closed the client! (whatever that means...)");
  }

  pauseStream() {
//    fibonacciStreamSubscription.pause();
    toggleStreamStatus();
  }

  resumeStream() {
//    fibonacciStreamSubscription.resume();
    toggleStreamStatus();
  }

  cancelStream() {
//    fibonacciStreamSubscription.cancel();
    print("CANCel THe STREAM");
  }

  toggleStreamStatus() {
    setState(() {
      isStreamPaused = !isStreamPaused;
    });
  }

  @override
  void dispose() {
    closeClient();
//    fibonacciStreamSubscription.cancel();
    super.dispose();
  }
}
