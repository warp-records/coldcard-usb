import 'dart:typed_data';

import 'package:coldcard_protocol/coldcard_transport.dart';
import 'package:ledger_usb_plus/ledger_usb.dart';
import 'package:ledger_usb_plus/ledger_usb_platform_interface.dart';

class ColdcardUsbTransport implements ColdcardTransport {
  final _usb = LedgerUsb();

  @override
  Future<bool> open(int vendorId, int productId) async {
    final devices = await _usb.listDevices();
    final device = devices
        .firstWhere((d) => d.vendorId == vendorId && d.productId == productId);
    final granted = await _usb.requestPermission(device);
    if (!granted) return false;

    return await _usb.open(device);
  }

  @override
  Future<int> write(Uint8List data) async {
    // change timeout later?
    return LedgerUsbPlatform.instance.transferOut(data, 3000);
  }

  @override
  Future<Uint8List> read(int len, int timeout) async {
    var data = await LedgerUsbPlatform.instance.transferIn(len, timeout);
    data ??= Uint8List(0);

    return data;
  }
}
