import 'package:battery_alarm_app/bt/scanner.dart';
import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:battery_alarm_app/model/bt_uuid.dart';
import 'package:battery_alarm_app/text.dart';
import 'package:battery_alarm_app/widgets/about_app_dialog.dart';
import 'package:battery_alarm_app/widgets/scan_fab_widget.dart';
import 'package:battery_alarm_app/widgets/scan_result_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class DeviceScannerWidget extends StatelessWidget {
  DeviceScannerWidget({
    super.key,
    required this.deviceClient,
    this.error,
  });

  final scanner = BleScanner();
  final DeviceClient deviceClient;
  final GenericFailure<ConnectionError>? error;

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: scanner.state,
        initialData: scanner.stateSnapshot,
        builder: (context, scannerState) => _DeviceScanWidget(
          bleScanner: scanner,
          deviceClient: deviceClient,
          scannerState: scannerState,
          error: error,
        ),
      );
}

class _DeviceScanWidget extends StatefulWidget {
  const _DeviceScanWidget({
    super.key,
    required this.bleScanner,
    required this.deviceClient,
    required this.scannerState,
    this.error,
  });

  final BleScanner bleScanner;
  final DeviceClient deviceClient;
  final AsyncSnapshot<BleScannerState> scannerState;
  final GenericFailure<ConnectionError>? error;

  @override
  State<StatefulWidget> createState() => _DeviceScanState();
}

class _DeviceScanState extends State<_DeviceScanWidget> {
  @override
  void initState() {
    super.initState();
    _startScan();
    _onError();
  }

  @override
  void dispose() {
    _stopScan();
    super.dispose();
  }

  Future<void> _startScan() async {
    await widget.deviceClient.disconnect();
    widget.bleScanner.startScan([uuidStatusService, uuidConfigService]);
  }

  Future<void> _stopScan() async => widget.bleScanner.stopScan();

  Widget _onEmpty(bool scanning) => Center(
        child: Text(scanning
            ? 'Suche nach Battalarm Adaptern...'
            : 'Keine Adapter gefunden'),
      );

  void _onError() {
    if (widget.error == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(
        content: Text('Die Verbindung wurde unterbrochen.'),
      ));
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
          MenuItemButton(
            onPressed: () => showAboutAppDialog(context),
            child: const Text(Texts.aboutAppMenuItemTitle),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(Texts.appTitle),
          actions: [_appMenu(context)],
        ),
        body: RefreshIndicator(
          onRefresh: _startScan,
          child: Column(
            children: [
              _paddedText(
                  'Wenn der Adapter nicht gefunden wird, dann halte den Knopf am Adapter für ca. 5 Sekunden lang gedrückt, bis ein tiefer Piepton kommt.'),
              Expanded(
                child: ScanResultWidget(
                  state: widget.scannerState.data,
                  onEmpty: _onEmpty(widget.scannerState.data?.scanIsInProgress ?? false),
                  onSelect: (device) => widget.deviceClient.connect(device.id),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: ScanFabWidget(
          state: widget.scannerState.data,
          onStartScan: _startScan,
          onStopScan: _stopScan,
        ),
      );
}

Widget _paddedText(String text) => Padding(
      padding: const EdgeInsets.all(16),
      child: Text(text),
    );
