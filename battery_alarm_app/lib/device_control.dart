import 'package:battery_alarm_app/about_widget.dart';
import 'package:battery_alarm_app/device_config_widget.dart';
import 'package:battery_alarm_app/device_status_widget.dart';
import 'package:flutter/material.dart';

class DeviceControlWidget extends StatelessWidget {
  const DeviceControlWidget({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Batterie Alarm'),
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.info_outline),
                  text: 'Status',
                ),
                Tab(
                  icon: Icon(Icons.settings),
                  text: 'Einstellungen',
                ),
                Tab(
                  icon: Icon(Icons.help_outline),
                  text: 'Hilfe',
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              DeviceStatusWidget(),
              DeviceConfigWidget(),
              AboutWidget(),
            ],
          ),
        ),
      );
}
