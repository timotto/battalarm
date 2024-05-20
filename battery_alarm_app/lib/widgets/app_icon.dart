import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    this.size,
  });

  final double? size;

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    final double? iconSize = size ?? iconTheme.size;

    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: Image.asset("assets/icon/icon.png"),
    );
  }
}
