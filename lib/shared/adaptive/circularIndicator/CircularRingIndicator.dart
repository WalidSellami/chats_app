import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CircularRingIndicator extends StatelessWidget {
  final String os;
  const CircularRingIndicator({super.key, required this.os});

  @override
  Widget build(BuildContext context) {
    if (os == 'android') {
      return SpinKitRing(
        color: Theme.of(context).colorScheme.primary,
        size: 30.0,
        lineWidth: 3.0,
      );
    } else {
      return SpinKitFadingCircle(
        color: Theme.of(context).colorScheme.primary,
        size: 30.0,
      );
    }
  }
}
