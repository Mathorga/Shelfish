import 'package:flutter/material.dart';

import 'package:shelfless/themes/themes.dart';

class SeparatorWidget extends StatelessWidget {
  final Widget? child;

  const SeparatorWidget({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Themes.spacingMedium),
      child: Center(child: child),
    );
  }
}
