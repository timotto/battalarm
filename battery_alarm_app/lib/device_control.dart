import 'package:battery_alarm_app/about_widget.dart';
import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:battery_alarm_app/device_config_widget.dart';
import 'package:battery_alarm_app/device_status_widget.dart';
import 'package:battery_alarm_app/text.dart';
import 'package:flutter/material.dart';

class DeviceControlWidget extends StatefulWidget {
  const DeviceControlWidget({super.key, required this.deviceClient});

  final DeviceClient deviceClient;

  @override
  State<StatefulWidget> createState() => _DeviceControlWidgetState();
}

class _DeviceControlWidgetState extends State<DeviceControlWidget> {
  bool _expert = false;

  void _toggleExpertMode(bool? value) {
    setState(() {
      _expert = value ?? false;
    });
  }

  Widget _appMenu(BuildContext context) => MenuAnchor(
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
          CheckboxMenuButton(
            value: _expert,
            onChanged: _toggleExpertMode,
            child: const Text('Experten Ansicht'),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(Texts.appTitle),
            actions: [_appMenu(context)],
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
            stream: widget.deviceClient.busy.stream,
            initialData: widget.deviceClient.busy.value,
            builder: (context, busy) => Column(
              children: [
                LinearProgressIndicator(
                  value: busy.data ?? false ? null : 0,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      DeviceStatusWidget(
                        deviceClient: widget.deviceClient,
                      ),
                      DeviceConfigWidget(
                        deviceClient: widget.deviceClient,
                        expert: _expert,
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
