import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../ui/themes.dart';

class LoadingEmployee extends StatelessWidget {
  const LoadingEmployee({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.flickr(
              leftDotColor: kSunColorPri,
              rightDotColor: kNightColorPri,
              size: 60.0,
            ),
            Text(
              'Loading...',
              style: smallTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}
