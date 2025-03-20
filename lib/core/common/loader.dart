import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../features/auth/login_screen.dart';


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
          Center(
            child: Text('You Account is temporary blocked'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                ModalRoute.withName('/'), // HomeScreen route
              );
            },
            child: Text('Back'),
          )
        ],
      ),
    );
  }
}
