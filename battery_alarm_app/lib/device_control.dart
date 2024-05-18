import 'package:battery_alarm_app/about_widget.dart';
import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:battery_alarm_app/device_config_widget.dart';
import 'package:battery_alarm_app/device_status_widget.dart';
import 'package:battery_alarm_app/text.dart';
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
            title: const Text(Texts.appTitle),
          ),
          bottomNavigationBar: const TabBar(
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
          body: StreamBuilder(
            stream: deviceClient.busy.stream,
            initialData: deviceClient.busy.value,
            builder: (context, busy) => Column(
              children: [
                LinearProgressIndicator(
                  value: busy.data ?? false ? null : 0,
                ),
                Expanded(
                  child: TabBarView(
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
              ],
            ),
          ),
        ),
      );
}
