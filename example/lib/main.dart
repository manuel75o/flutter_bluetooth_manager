// ignore_for_file: avoid_print

import 'dart:io';

import 'package:example/bluetooth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_manager/flutter_bluetooth_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: false);
  runApp(const ProviderScope(child: MyBluetoothManager()));
}

class MyBluetoothManager extends ConsumerStatefulWidget {
  const MyBluetoothManager({super.key});

  @override
  ConsumerState<MyBluetoothManager> createState() => _MyBluetoothManagerState();
}

class _MyBluetoothManagerState extends ConsumerState<MyBluetoothManager> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'FlutterBluetoothManager',
      home: MyManagerPage(),
    );
  }
}

/// Main Colors to use
const Color primRedNew = Colors.red;
const Color primGreyNew = Color(0xffE5E5E5);
const Color primBlueNew = Color.fromARGB(255, 55, 165, 238);
const Color primBlack = Color(0xff252525);

/// Global Variales
late BluetoothDevice targetDevice;
List<Stream<List<int>>> stream = [];
List<bool> isInitializedList = [];
bool showAllDevices = false;
bool showAllConnectedDevices = false;

class MyManagerPage extends ConsumerStatefulWidget {
  const MyManagerPage({super.key});

  @override
  ConsumerState<MyManagerPage> createState() => _MyManagerPageState();
}

class _MyManagerPageState extends ConsumerState<MyManagerPage> {
  /// Create an instance of FlutterBluePlus
  FlutterBluePlus flutterBluePlus = FlutterBluePlus();

  /// Create an instance of BluetoothManager
  BluetoothManager bluetoothManager = BluetoothManager();

  /// Basic Functions of FlutterBluePlus
  @override
  void initState() {
    enableBLE();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

//-----------------------------Enable BLE-----------------------------
  enableBLE() async {
    // check if BLE is supported
    if (await FlutterBluePlus.isSupported == false) {
      print("BLE is not supported by this device!");
      return;
    }

    // turn on bluetooth ourself if we can
    // for iOS, the user controls bluetooth enable/disable
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }

    // wait bluetooth to be on
    // note: for iOS the initial state is typically BluetoothAdapterState.unknown
    await FlutterBluePlus.adapterState
        .where((s) => s == BluetoothAdapterState.on)
        .first;
  }

//-----------------------------Start the Scan-----------------------------
  startScan() async {
    FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 4)); //Starts Scanning for Devices
  }
//-----------------------------Stop the Scan-----------------------------

  stopScan() {
    FlutterBluePlus.stopScan(); //Stop Scanning for Devices
  }

  @override
  Widget build(BuildContext context) {
    /// Check if a device lost it's connection
    bluetoothManager.checkDeviceConnection();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeigth = MediaQuery.of(context).size.height;

    /// Get data from providers
    final scanResults = ref.watch(scanResultStreamProvider);
    final connectedDevices = ref.watch(connectedDevicesStreamProvider);
    final isScanning = ref.watch(isScanningStreamProvider);
    final deviceModels = bluetoothManager.getAllDeviceModels();

    // Test for Provider Stream
    /*final characteristic = deviceModels.isNotEmpty
        ? bluetoothManager.getCharacteristic(deviceModels.first.device, 1)
        : null;*/
    /*final deviceStream = ref
        .watch(deviceStreamProvider(device.isNotEmpty ? characteristic : null));*/
    //final stream = bluetoothManager.subscribeToStream(characteristic);

    /*bool isInitialized = deviceModels.isNotEmpty
        ? deviceModels.first.characteristicsStream[1].isInitialized
        : false;
    print("is: $isInitialized");*/

    print("Device Count ${bluetoothManager.getConnectedDeviceCount()}");
    print("Stream Count ${bluetoothManager.getStreamCount()}");
    if (bluetoothManager.deviceCount != 0) {
      isInitializedList = deviceModels.isNotEmpty
          ? deviceModels
              .map((deviceModel) =>
                  deviceModel.characteristicsStream[1].isInitialized)
              .toList()
          : [];
      print("is: $isInitializedList");
    } else {
      isInitializedList = [];
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "FlutterBluetoothManager",
          style: TextStyle(color: primBlack),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return FlutterBluePlus.startScan(
              timeout:
                  const Duration(seconds: 4)); //Starts Scanning for Devices
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Flex(
                direction: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isScanning.when(
                    data: (data) {
                      if (data) {
                        return stopScanButton();
                      } else {
                        return startScanButton();
                      }
                    },
                    error: (error, stackTrace) {
                      return startScanButton();
                    },
                    loading: () {
                      return startScanButton();
                    },
                  )
                ],
              ),
              const SizedBox(height: 32),
              // Test for Provider Stream
              /*Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                  child: device.isNotEmpty
                      ? deviceStream.when(
                          data: (data) =>
                              Text(BluetoothManager().dataParser(data)),
                          error: (error, stackTrace) => const Text("Error"),
                          loading: () => const Text("Loading"),
                        )
                      : (const Text("No Device"))),*/
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 150,
                  child: deviceModels.isNotEmpty
                      ? ListView.builder(
                          itemCount: isInitializedList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return StreamBuilder<List<int>>(
                              stream: bluetoothManager.getStream(
                                  index), // Use the controlled stream
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.active &&
                                    snapshot.hasData) {
                                  return Text(bluetoothManager
                                      .dataParser(snapshot.data!)
                                      .toString());
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return const Center(
                                      child: Text("No stream initialized!"));
                                }
                              },
                            );
                          },
                        )
                      : const Center(child: Text("No Device connected!")),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Flex(
                  direction: Axis.horizontal,
                  children: [
                    const Text(
                      "Connected Devices",
                      style: TextStyle(fontSize: 22),
                    ),
                    Expanded(
                      child: SwitchListTile(
                        value: showAllConnectedDevices,
                        title: const Text(
                          "All",
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                        onChanged: (val) {
                          setState(() {
                            showAllConnectedDevices = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                child: connectedDevices.when(
                  data: (data) {
                    final espDevices = data
                        .where((device) => device.platformName.contains('ESP'))
                        .toList();
                    final connectedDevices =
                        showAllConnectedDevices ? data : espDevices;
                    return SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: connectedDevices.length,
                        itemBuilder: (context, index) {
                          var device = connectedDevices[index];
                          return Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 8, 0, 8),
                            child: Container(
                              width: screenWidth,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: primGreyNew,
                              ),
                              child: ListTile(
                                title: Text(device.platformName),
                                subtitle: Text(device.remoteId.toString()),
                                leading: isInitializedList.isNotEmpty
                                    ? !isInitializedList[index]
                                        ? openStreamButton(device, index)
                                        : closeStreamButton(device, index)
                                    : const Text("Loading"),
                                trailing:
                                    StreamBuilder<BluetoothConnectionState>(
                                  stream: device.connectionState,
                                  initialData:
                                      BluetoothConnectionState.disconnected,
                                  builder: (context, snapshot) {
                                    if (snapshot.data ==
                                        BluetoothConnectionState.connected) {
                                      return disconnectButton(device);
                                    }
                                    return const Text("Disconnecting");
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  error: (error, stackTrace) {
                    return Text(error.toString());
                  },
                  loading: () {
                    return const Text("No Devices Connected");
                  },
                ),
              ),
              const Divider(),
              SizedBox(
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [
                      const Text(
                        "All Devices",
                        style: TextStyle(fontSize: 22),
                      ),
                      Expanded(
                        child: SwitchListTile(
                          value: showAllDevices,
                          title: const Text(
                            "All",
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                          onChanged: (val) {
                            setState(() {
                              showAllDevices = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                child: scanResults.when(
                  data: (List<ScanResult> data) {
                    final espResults = data
                        .where((result) =>
                            result.device.platformName.contains('ESP'))
                        .toList();
                    final showDevices = showAllDevices ? data : espResults;
                    return SizedBox(
                      height: screenHeigth,
                      child: ListView.builder(
                        itemCount: showDevices.length,
                        itemBuilder: (BuildContext context, int index) {
                          final result = showDevices[index];

                          return Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 8, 0, 8),
                            child: Container(
                              height: 100,
                              width: screenWidth,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: primGreyNew,
                              ),
                              child: ListTile(
                                title: Text(result.device.platformName),
                                subtitle:
                                    Text(result.device.remoteId.toString()),
                                leading: Text(
                                  result.rssi.toString(),
                                ),
                                trailing: connectButton(result.device),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  error: (error, stackTrace) {
                    return Text(error.toString());
                  },
                  loading: () {
                    return const Text("No Devices Found");
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  startScanButton() {
    return SizedBox(
      height: 75,
      child: TextButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primBlueNew,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        child:
            const Text('Scan for Devices', style: TextStyle(color: primBlack)),
        onPressed: () {
          startScan();
        },
      ),
    );
  }

  stopScanButton() {
    return SizedBox(
      height: 75,
      child: TextButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primRedNew,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        child:
            const Text('Scan for Devices', style: TextStyle(color: primBlack)),
        onPressed: () {
          stopScan();
        },
      ),
    );
  }

  connectButton(device) {
    return SizedBox(
      height: 35,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: primBlueNew,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          targetDevice = device;
          print("TARGET DEVICE: $targetDevice");
          bluetoothManager.connectDevice(targetDevice);
        },
        child: const Text(
          'Connect',
          style: TextStyle(
              color: primBlack, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  disconnectButton(device) {
    return SizedBox(
      height: 35,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: primRedNew,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          targetDevice = device;
          bluetoothManager.disconnectDevice(targetDevice);
        },
        child: const Text(
          'Disconnect',
          style: TextStyle(
              color: primBlack, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  openStreamButton(device, index) {
    return SizedBox(
      height: 35,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          // Open stream for a device with a given index
          bluetoothManager.streamHandler(
              index,
              bluetoothManager
                  .openStream(bluetoothManager.getCharacteristic(device, 1)));
          // Initialize the current stream of it's device
          bluetoothManager
              .deviceModel[index].characteristicsStream[1].isInitialized = true;
        },
        child: const Text(
          'Open Stream',
          style: TextStyle(
              color: primBlack, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  closeStreamButton(device, index) {
    return SizedBox(
      height: 35,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: primRedNew,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          // Close stream for a device with a given index
          bluetoothManager.closeStream(index);

          bluetoothManager.deviceModel[index].characteristicsStream[1]
              .isInitialized = false;
        },
        child: const Text(
          'Close Stream',
          style: TextStyle(
              color: primBlack, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
