import 'package:battery_alarm_app/about_widget.dart';
import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:battery_alarm_app/device_config_widget.dart';
import 'package:battery_alarm_app/device_status_widget.dart';
import 'package:battery_alarm_app/ota/ota_dialog.dart';
import 'package:battery_alarm_app/text.dart';
import 'package:battery_alarm_app/widgets/app_menu_widget.dart';
import 'package:flutter/material.dart';

class DeviceControlWidget extends StatefulWidget {
  DeviceControlWidget({super.key});

  final _deviceClient = DeviceClient();

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

  void _onUpdate(BuildContext context) => OtaDialog.show(context);

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(Texts.appTitle()),
            actions: [
              AppMenuWidget(
                menuItems: [
                  CheckboxMenuButton(
                    value: _expert,
                    onChanged: _toggleExpertMode,
                    child: Text(Texts.menuItemExpertView()),
                  ),
                  if (_expert)
                    StreamBuilder(
                      stream: widget._deviceClient.otaService.versionStream,
                      initialData: widget._deviceClient.otaService.version,
                      builder: (_, version) => MenuItemButton(
                        onPressed: version.data == null
                            ? null
                            : () => _onUpdate(context),
                        child: Text(Texts.menuItemUpdateAdapterFirmware()),
                      ),
                    ),
                ],
              )
            ],
          ),
          bottomNavigationBar: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.info_outline),
                text: Texts.tabLabelStatus(),
              ),
              Tab(
                icon: const Icon(Icons.settings),
                text: Texts.tabLabelSettings(),
              ),
              Tab(
                icon: const Icon(Icons.help_outline),
                text: Texts.tabLabelHelp(),
              ),
            ],
          ),
          body: StreamBuilder(
            stream: widget._deviceClient.busy.stream,
            initialData: widget._deviceClient.busy.value,
            builder: (context, busy) => Column(
              children: [
                LinearProgressIndicator(
                  value: busy.data ?? false ? null : 0,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      DeviceStatusWidget(
                        deviceClient: widget._deviceClient,
                        expert: _expert,
                      ),
                      DeviceConfigWidget(
                        deviceClient: widget._deviceClient,
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
