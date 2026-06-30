import 'dart:typed_data';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'usb_device.dart';
import 'ledger_usb_method_channel.dart';

abstract class ColdcardUsbPlatform extends PlatformInterface {
  ColdcardUsbPlatform() : super(token: _token);

  static final Object _token = Object();

  static ColdcardUsbPlatform _instance = MethodChannelColdcardUsb();

  static ColdcardUsbPlatform get instance => _instance;

  static set instance(ColdcardUsbPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<UsbDevice>> getDevices();

  Future<bool> requestPermission(UsbDevice usbDevice);

  Future<bool> open(UsbDevice usbDevice);

  Future<Uint8List?> transferIn(int packetSize, int timeout);

  Future<int> transferOut(Uint8List data, int timeout);

  Future<bool> close();
}
