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

TODO: List what your package can do. Maybe include images, gifs, or videos.


### Getting Started

To get started you simply create an instance of the BluetoothManager.
```dart
  BluetoothManager bluetoothManager = BluetoothManager();
```
Connect/Disconnect a device:
```dart
connectDevice(BluetoothDevice device);
disconnectDevice(BluetoothDevice device);
```
Check device ConnectionState. A common problem is, if you accidently lose connection to a device it can lead to an exeption. With this function you constantly check the device connectionState for all connected devices and if it loses a connection the device will be disconnected and removed from the DeviceModel leading to no exeptions or potential errors.

```dart
checkDeviceConnection();
```
To retrieve a Characteristic for subscribing to a stream or writing message you can perform this by calling `getCharacteristic`. Since there can be multiple Characteristics per Service you can choose it by Number.
```dart
getCharacteristic(BluetoothDevice device, int characteristicNumber);
```
Subscribe to a Stream. It will return a List<int>.
```dart
subscribeToStream(BluetoothCharacteristic? characteristic);
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.


