import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../features/auth/login_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
      // widthFactor: 60,
      // heightFactor: 60,
      // child: LoadingAnimationWidget.prograssiveDots(color: Colors.black, size: 60)
    );
  }
}

class Globals {
  static bool isLoading = false;
  static String value = '';
}

class TimerLoader extends StatefulWidget {
  const TimerLoader({Key? key}) : super(key: key);

  @override
  _TimerLoaderState createState() => _TimerLoaderState();
}

class _TimerLoaderState extends State<TimerLoader> {
  late Timer _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Start the timer when the widget is initialized
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Your timer logic goes here
      setState(() {
        _isLoading = false; // Set loading state to false when timer expires
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Your content

        // Circular Progress Indicator
        if (_isLoading) CircularProgressIndicator(),
      ],
    );
  }

  @override
  void dispose() {
    // Dispose the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }
}

class Loaders extends StatelessWidget {
  const Loaders({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: Text('You Account is temporary blocked')),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                ModalRoute.withName('/'), // HomeScreen route
              );
            },
            child: Text('Back'),
          ),
        ],
      ),
    );
  }
}

Future<void> loadingIndicator() async {
  const apiKey = 'AIzaSyA2dXKJuE4ZaThjyb4ifRgPQkg7HN5F36A';
  const projectId = 'shopapp-73256';
  const collectionName = 'meetcross';

  final url =
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$collectionName?key=$apiKey';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final firstDoc = data['documents'][0]['fields'];

      Globals.isLoading = firstDoc['loading']['booleanValue'];
      Globals.value = firstDoc['message']['stringValue'];
      print('loading value is ${Globals.isLoading}');
    } else {
      debugPrint('Failed to fetch data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error fetching Firestore data: $e');
  }
}

class Loadings extends StatelessWidget {
  const Loadings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade900, // Dark red background
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              Globals.value,
              style: TextStyle(
                color: Colors.yellowAccent.shade100,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
