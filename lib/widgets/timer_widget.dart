import 'dart:async';
import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  int secondsLeft = 120; // 2 minutes for example
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (secondsLeft > 0) {
        setState(() {
          secondsLeft--;
        });
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.blue,
      child: Text(
        "Time Left: ${secondsLeft}s",
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}
