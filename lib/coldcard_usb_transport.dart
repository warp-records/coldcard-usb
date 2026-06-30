import 'dart:typed_data';

import 'package:coldcard_protocol/coldcard_transport.dart';

import 'ledger_usb_platform_interface.dart';

class ColdcardUsbTransport implements ColdcardTransport {
  @override
  Future<bool> open(int vendorId, int productId) async {
    final devices = await ColdcardUsbPlatform.instance.getDevices();
    final device = devices
        .firstWhere((d) => d.vendorId == vendorId && d.productId == productId);
    final granted = await ColdcardUsbPlatform.instance.requestPermission(device);
    if (!granted) return false;

    return await ColdcardUsbPlatform.instance.open(device);
  }

  @override
  Future<int> write(Uint8List data) async {
    return ColdcardUsbPlatform.instance.transferOut(data, 3000);
  }

  @override
  Future<Uint8List> read(int len, int timeout) async {
    var data = await ColdcardUsbPlatform.instance.transferIn(len, timeout);
    data ??= Uint8List(0);

    return data;
  }
}
