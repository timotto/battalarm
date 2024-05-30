import 'package:battery_alarm_app/bt/scanner.dart';
import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:battery_alarm_app/model/bt_uuid.dart';
import 'package:battery_alarm_app/text.dart';
import 'package:battery_alarm_app/widgets/app_menu_widget.dart';
import 'package:battery_alarm_app/widgets/scan_fab_widget.dart';
import 'package:battery_alarm_app/widgets/scan_result_widget.dart';
import 'package:battery_alarm_app/widgets/scanning_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DeviceScannerWidget extends StatefulWidget {
  DeviceScannerWidget({
    super.key,
    this.error,
  });

  final bleScanner = BleScanner();
  final deviceClient = DeviceClient();
  final GenericFailure<ConnectionError>? error;

  @override
  State<StatefulWidget> createState() => _DeviceScannerWidgetState();
}

class _DeviceScannerWidgetState extends State<DeviceScannerWidget> {
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
        child: scanning
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoadingAnimationWidget.stretchedDots(
                    color: Colors.red,
                    size: 96,
                  ),
                  Text(Texts.deviceScannerSearching()),
                ],
              )
            : Text(Texts.deviceScannerNoResults()),
      );

  void _onError() {
    if (widget.error == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
        content: Text(Texts.deviceScannerError()),
      ));
    });
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: widget.bleScanner.state,
        initialData: widget.bleScanner.stateSnapshot,
        builder: (context, scannerState) => Scaffold(
          appBar: AppBar(
            title: Text(Texts.appTitle()),
            actions: const [AppMenuWidget()],
          ),
          body: RefreshIndicator(
            onRefresh: _startScan,
            child: Column(
              children: [
                ScanningIndicatorWidget(
                  value: scannerState.data?.scanIsInProgress,
                ),
                _paddedText(Texts.deviceScannerHint()),
                Expanded(
                  child: ScanResultWidget(
                    state: scannerState.data,
                    onEmpty:
                        _onEmpty(scannerState.data?.scanIsInProgress ?? false),
                    onSelect: (device) =>
                        widget.deviceClient.connect(device.id),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: ScanFabWidget(
            state: scannerState.data,
            onStartScan: _startScan,
            onStopScan: _stopScan,
          ),
        ),
      );
}

Widget _paddedText(String text) => Padding(
      padding: const EdgeInsets.all(16),
      child: Text(text),
    );
