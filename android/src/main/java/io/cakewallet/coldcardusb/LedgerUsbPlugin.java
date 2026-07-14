package io.cakewallet.coldcardusb;

import android.content.Context;
import android.hardware.usb.UsbManager;

import androidx.annotation.NonNull;

import io.cakewallet.coldcardusb.operations.CloseOperation;
import io.cakewallet.coldcardusb.operations.ConnectOperation;
import io.cakewallet.coldcardusb.operations.GetDevicesOperation;
import io.cakewallet.coldcardusb.operations.MethodCallRegistry;
import io.cakewallet.coldcardusb.operations.RequestPermissionOperation;
import io.cakewallet.coldcardusb.operations.TransferInOperation;
import io.cakewallet.coldcardusb.operations.TransferOutOperation;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.StandardMethodCodec;

public class LedgerUsbPlugin implements FlutterPlugin, MethodCallHandler {

    private MethodChannel channel;
    private Context context;
    private UsbManager usbManager;
    private MethodCallRegistry registry;
    private LedgerManager ledgerManager;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        BinaryMessenger.TaskQueue taskQueue = binding.getBinaryMessenger().makeBackgroundTaskQueue();
        channel = new MethodChannel(
                binding.getBinaryMessenger(), "coldcard_usb", StandardMethodCodec.INSTANCE, taskQueue);
        channel.setMethodCallHandler(this);
        context = binding.getApplicationContext();
        usbManager = (UsbManager) context.getSystemService(Context.USB_SERVICE);
        ledgerManager = new LedgerManager(usbManager);

        // Register the method calls
        registry = new MethodCallRegistry();
        registry.registerMethodCall("getDevices", new GetDevicesOperation(ledgerManager));
        registry.registerMethodCall("requestPermission", new RequestPermissionOperation(ledgerManager));
        registry.registerMethodCall("open", new ConnectOperation(ledgerManager));
        registry.registerMethodCall("close", new CloseOperation(ledgerManager));
        registry.registerMethodCall("transferIn", new TransferInOperation(ledgerManager));
        registry.registerMethodCall("transferOut", new TransferOutOperation(ledgerManager));
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        registry.onMethodCall(context, call, result);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        registry.clear();
        registry = null;
        usbManager = null;
        ledgerManager = null;
        context = null;
    }

}
