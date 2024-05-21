import 'package:battery_alarm_app/text.dart';
import 'package:battery_alarm_app/widgets/about_app_dialog.dart';
import 'package:flutter/material.dart';

class AppMenuWidget extends StatelessWidget {
  const AppMenuWidget({
    super.key,
    this.menuItems,
  });

  final List<Widget>? menuItems;

  @override
  Widget build(BuildContext context) => MenuAnchor(
        builder: (context, controller, _) => IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.more_vert),
        ),
        menuChildren: [
          if (menuItems != null) ...menuItems!,
          MenuItemButton(
            onPressed: () => showAboutAppDialog(context),
            child: const Text(Texts.aboutAppMenuItemTitle),
          ),
        ],
      );
}
