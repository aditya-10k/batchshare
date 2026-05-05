import 'package:flutter/material.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget portraitView;
  final Widget landscapeView;

  const ResponsiveWidget({
    required this.portraitView,
    required this.landscapeView,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // if (!kIsWeb) {
        //   return portraitView;
        // }
        return constraints.maxWidth > constraints.maxHeight
            ? landscapeView
            : portraitView;
      },
    );
  }
}
