import 'package:battery_alarm_app/bt/scanner.dart';
import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:battery_alarm_app/model/bt_uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class DeviceScannerWidget extends StatelessWidget {
  DeviceScannerWidget({
    super.key,
    required this.deviceClient,
  });

  final scanner = BleScanner();
  final DeviceClient deviceClient;

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: scanner.state,
        initialData: scanner.stateSnapshot,
        builder: (context, scannerState) => _DeviceScanWidget(
          bleScanner: scanner,
          deviceClient: deviceClient,
          scannerState: scannerState,
        ),
      );
}

class _DeviceScanWidget extends StatefulWidget {
  const _DeviceScanWidget({
    super.key,
    required this.bleScanner,
    required this.deviceClient,
    required this.scannerState,
  });

  final BleScanner bleScanner;
  final DeviceClient deviceClient;
  final AsyncSnapshot<BleScannerState> scannerState;

  @override
  State<StatefulWidget> createState() => _DeviceScanState();
}

class _DeviceScanState extends State<_DeviceScanWidget> {
  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _stopScan();
    super.dispose();
  }

  BleScannerState _scannerState() {
    return widget.scannerState.data ??
        const BleScannerState(
          discoveredDevices: [],
          scanIsInProgress: false,
        );
  }

  Future<void> _startScan() async {
    await widget.deviceClient.disconnect();
    widget.bleScanner.startScan([uuidStatusService, uuidConfigService]);
  }

  Future<void> _stopScan() async => widget.bleScanner.stopScan();

  Widget _fab() {
    if (_scannerState().scanIsInProgress) {
      return FloatingActionButton(
        onPressed: _stopScan,
        backgroundColor: Colors.red,
        child: const Icon(Icons.stop),
      );
    }

    return FloatingActionButton(
      onPressed: _startScan,
      child: const Icon(Icons.search),
    );
  }

  Widget _resultList(
      BuildContext context, List<DiscoveredDevice> results, bool scanning) {
    if (results.isEmpty) {
      return Center(
        child: Text(scanning
            ? 'Suche nach Battalarm Adaptern...'
            : 'Keine Adapter gefunden'),
      );
    }
    final cpy = List<DiscoveredDevice>.from(results);
    cpy.sort(_scanResultSorter);
    return ListView(
      children: cpy
          .map<Widget>(
            (result) => _ScanResultTile(
              result: result,
              onTap: () {
                widget.deviceClient.connect(result.id);
              },
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Battalarm'),
        ),
        body: RefreshIndicator(
          onRefresh: _startScan,
          child: Column(
            children: [
              _paddedText(
                  'Wenn der Adapter nicht gefunden wird, dann halte den Knopf am Adapter für ca. 5 Sekunden lang gedrückt, bis ein tiefer Piepton kommt.'),
              Expanded(
                child: _resultList(context, _scannerState().discoveredDevices,
                    _scannerState().scanIsInProgress),
              ),
            ],
          ),
        ),
        floatingActionButton: _fab(),
      );
}

Widget _paddedText(String text) => Padding(
      padding: const EdgeInsets.all(16),
      child: Text(text),
    );

class _ScanResultTile extends StatelessWidget {
  const _ScanResultTile({
    super.key,
    required this.result,
    required this.onTap,
  });

  final DiscoveredDevice result;
  final void Function() onTap;

  String get _name => result.name.isNotEmpty ? result.name : result.id;

  Widget? get _subtitle => result.name.isNotEmpty ? Text(result.id) : null;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(_name),
        subtitle: _subtitle,
        onTap: onTap,
      );
}

int _scanResultSorter(DiscoveredDevice a, DiscoveredDevice b) {
  if (a.name.isNotEmpty && b.name.isEmpty) return -1;
  if (b.name.isNotEmpty && a.name.isEmpty) return 1;

  final result = a.name.compareTo(b.name);
  if (result != 0) return result;

  return a.id.compareTo(b.id);
}
