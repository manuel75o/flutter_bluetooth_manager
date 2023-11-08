The aim of `FlutterBluetoothManager` is to handle multiple devices and their streams with ease. It is built on top of the Flutter Bluetooth Package `FlutterBluePlus`.

## Manager

The BluetoothManager creates a DeviceModel. This represents the device and it's corresponding Services and Characteristics. A device is unique to a DeviceModel. There can be multiple Services and Characteristics per DeviceModel.

The general Structure looks like this:
```dart
class DeviceModel {
  final BluetoothDevice device;
  final List<BluetoothService> services;
  final List<CharacteristicStream> characteristicsStream;
  DeviceModel(this.device, this.services, this.characteristicsStream);
}
```
CharacteristicStream contains the BluetoothCharacteristic and Info wether it's Stream is initialized.
```dart
class CharacteristicStream {
  final BluetoothCharacteristic characteristic;
  bool isInitialized;
  CharacteristicStream({
    required this.characteristic,
    this.isInitialized = false,
  });
}
```

## Features
![Search for devices](resources/DD05AF0C-8434-43A1-A1D6-C9221B7B93C6_1_105_c.jpeg | width=125)
![Connect multiple devices](resources/B92488A3-63E6-49CD-BEF6-B67395B7D6A2_1_105_c.jpeg | width=125)
![Open single Streams](resources/922BA714-DDB9-4535-AF41-F161573E8046_1_105_c.jpeg | width=125)
![Open multiple Streams](resources/92D4F7DF-A796-4F4E-B6E3-03C89D6646CF_1_105_c.jpeg | width=125)

### Getting Started

To get started you simply create an instance of the BluetoothManager.
```dart
  BluetoothManager bluetoothManager = BluetoothManager();
```
Connect/Disconnect a device:
```dart
bluetoothManager.connectDevice(BluetoothDevice device);
bluetoothManager.disconnectDevice(BluetoothDevice device);
```
Check device ConnectionState. A common problem is, if you accidently lose connection to a device it can lead to an exeption. With this function you constantly check the device connectionState for all connected devices and if it loses a connection the device will be disconnected and removed from the DeviceModel leading to no exeptions or potential errors.

```dart
bluetoothManager.checkDeviceConnection();
```
To retrieve a Characteristic for subscribing to a stream or writing message you can perform this by calling `getCharacteristic`. Since there can be multiple Characteristics per Service you can choose it by Number.
```dart
bluetoothManager.getCharacteristic(BluetoothDevice device, int characteristicNumber);
```

Open a stream by simply calling the streamHandler. It takes the device index value and a stream as input.
```dart
bluetoothManager.streamHandler(index,bluetoothManager.openStream(BluetoothCharacteristic? characteristic));
```

Retrieve a stream for Streambuilder by its device index
```dart
bluetoothManager.getStream(index)
```

Close a stream
```dart
bluetoothManager.closeStream(index)
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.


