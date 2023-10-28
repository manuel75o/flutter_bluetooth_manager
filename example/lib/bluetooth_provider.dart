// ignore_for_file: avoid_print

import 'package:flutter_bluetooth_manager/flutter_bluetooth_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//-----------------------------BluetoothManager Providers-----------------------------

//Stores a List of <Stream<List<int>>> --> for Streams
final deviceStreamProvider =
    StreamProvider.family<List<int>, BluetoothCharacteristic?>(
        (ref, characteristic) async* {
  await characteristic?.setNotifyValue(!characteristic.isNotifying);
  await characteristic?.read();

  if (characteristic != null) {
    final stream = characteristic.lastValueStream.asBroadcastStream();
    yield* stream;
  } else {
    print("Something went wrong");
  }
});

//Counts all active BLE Connections
final bluetoothConnectedDeviceCount = StateProvider((ref) => 0);

//-----------------------------FlutterBlue API Provider-----------------------------

//adapterState
final adapterStateStreamProvider = StreamProvider<BluetoothAdapterState>((ref) {
  final adapterState = FlutterBluePlus.adapterState;
  return adapterState;
});

//scanResult
final scanResultStreamProvider = StreamProvider<List<ScanResult>>((ref) async* {
  final resultsTemp = FlutterBluePlus.scanResults;

  await for (var results in resultsTemp) {
    final uniqueResults = results.toSet().toList(); // Filter out duplicates
    //print("LATEST RESULTS: $uniqueResults");
    yield uniqueResults;
  }
});

//isScanning
final isScanningStreamProvider = StreamProvider<bool>((ref) {
  final isScanning = FlutterBluePlus.isScanning;
  return isScanning;
});

//isScanningNow
final isScanningNowStreamProvider = StateProvider<bool>((ref) {
  final isScanningNow = FlutterBluePlus.isScanningNow;
  return isScanningNow;
});

//systemDevices
final connectedSystemDevicesStreamProvider =
    StreamProvider<List<BluetoothDevice>>((ref) async* {
  final connectedSystemDevicesTemp = Stream.periodic(const Duration(seconds: 5))
      .asyncMap((_) => FlutterBluePlus.systemDevices);
  await for (var devices in connectedSystemDevicesTemp) {
    final connectedSystemDevices =
        devices.toSet().toList(); // Filter out duplicates
    //print("LATEST RESULTS: $connectedDevices");
    yield connectedSystemDevices;
  }
});

//connectedDevices
final connectedDevicesStreamProvider =
    StreamProvider<List<BluetoothDevice>>((ref) async* {
  final connectedDevicesTemp = Stream.periodic(const Duration(seconds: 5))
      .asyncMap((_) => FlutterBluePlus.connectedDevices);
  await for (var devices in connectedDevicesTemp) {
    final connectedDevices = devices.toSet().toList(); // Filter out duplicates
    //print("LATEST RESULTS: $connectedDevices");
    yield connectedDevices;
  }
});
