import 'package:battery_alarm_app/about_widget.dart';
import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:battery_alarm_app/device_config_widget.dart';
import 'package:battery_alarm_app/device_status_widget.dart';
import 'package:flutter/material.dart';

class DeviceControlWidget extends StatelessWidget {
  const DeviceControlWidget({
    super.key,
    required this.deviceClient,
  });

  final DeviceClient deviceClient;

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
          body: TabBarView(
            children: [
              DeviceStatusWidget(
                deviceClient: deviceClient,
              ),
              DeviceConfigWidget(
                deviceClient: deviceClient,
              ),
              const AboutWidget(),
            ],
          ),
        ),
      );
}
