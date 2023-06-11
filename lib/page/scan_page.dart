import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:vibration/vibration.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_scan/page/my_qr_code_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  ScanPageState createState() => ScanPageState();
}

class ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  double _zoomScale = 0;
  MobileScannerController camera = MobileScannerController();

  @override
  void dispose() {
    super.dispose();
    camera.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        //在前台激活
        if (!camera.isStarting) {
          camera.start();
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.paused:
        //在后台暂停
        camera.stop();
        break;
    }
  }

  //开关手电筒
  void _changeFlashMode() {
    camera.toggleTorch();
  }

  //双击放大或缩小
  void _changeZoomScale() {
    if (_zoomScale == 0) {
      _zoomScale = 1;
    } else {
      _zoomScale = 0;
    }
    camera.setZoomScale(_zoomScale);
  }

  //双指捏合放大或缩小
  void _onScaleChaneg(ScaleUpdateDetails details) {
    _zoomScale = (details.scale / 10 * 6 - 0.6).clamp(0, 1);
    camera.setZoomScale(_zoomScale);
  }

  //二维码详情展示
  Widget _scanResult(String result, MobileScannerController camera) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('扫码结果'),
        leading: BackButton(
          onPressed: () {
            camera.start();
            Get.back();
          },
        ),
      ),
      body: Wrap(children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(result),
        )
      ]),
    );
  }

  //扫描相机二维码
  Future<void> _scanQrCode(BarcodeCapture capture) async {
    if (await Vibration.hasVibrator() as bool) {
      Vibration.vibrate(duration: 100, amplitude: 200);
    }
    camera.stop();
    List<Barcode> barcodes = capture.barcodes;
    String result = barcodes[0].rawValue as String;
    if (GetUtils.isURL(result)) {
      await launchUrl(Uri.parse(result), mode: LaunchMode.externalApplication);
    } else {
      Get.to(_scanResult(result, camera));
    }
  }

  //扫描相册二维码
  Future<void> _scanLocalQrCode() async {
    List<AssetEntity>? qrCodes = await AssetPicker.pickAssets(
      context,
      pickerConfig: const AssetPickerConfig(
          maxAssets: 1,
          specialPickerType: SpecialPickerType.noPreview,
          requestType: RequestType.image),
    );
    try {
      late File file;
      await qrCodes![0].file.then((value) => file = value!);
      String result = await scanner.scanPath(file.path);

      if (await Vibration.hasVibrator() as bool) {
        Vibration.vibrate(duration: 100, amplitude: 200);
      }
      if (GetUtils.isURL(result)) {
        await launchUrl(Uri.parse(result),
            mode: LaunchMode.externalApplication);
      } else {
        Get.to(() => _scanResult(result, camera));
      }
    } catch (_) {}
  }

  //手电筒
  Widget _flashLightButton() {
    return GestureDetector(
      onTap: _changeFlashMode,
      child: const Column(
        children: [
          Icon(Icons.flashlight_on_outlined, size: 44, color: Colors.white),
          SizedBox(height: 8),
          Text(
            '轻触照亮',
            style: TextStyle(color: Colors.white, fontSize: 13),
          )
        ],
      ),
    );
  }

  //我的二维码
  Widget _myQrCode() {
    return GestureDetector(
      onTap: () {
        camera.stop();
        Get.to(() => MyQrCodePage(camera));
      },
      child: Column(children: [
        ClipOval(
            child: Container(
                padding: const EdgeInsets.all(10),
                color: const Color.fromRGBO(70, 70, 70, 1),
                child: const Icon(Icons.qr_code, color: Colors.white))),
        const SizedBox(height: 1),
        const Text(
          '我的二维码',
          style: TextStyle(color: Colors.white, fontSize: 11),
        )
      ]),
    );
  }

  //相册
  Widget _album() {
    return GestureDetector(
      onTap: _scanLocalQrCode,
      child: Column(children: [
        ClipOval(
            child: Container(
                padding: const EdgeInsets.all(10),
                color: const Color.fromRGBO(70, 70, 70, 1),
                child: const Icon(Icons.image, color: Colors.white))),
        const SizedBox(height: 1),
        const Text(
          '相册',
          style: TextStyle(color: Colors.white, fontSize: 11),
        )
      ]),
    );
  }

  //相机预览
  Widget _cameraView(MobileScanner scanner) {
    return GestureDetector(
        onDoubleTap: _changeZoomScale,
        onScaleUpdate: _onScaleChaneg,
        child: SizedBox(height: double.infinity, child: scanner));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(color: Colors.black),
      _cameraView(MobileScanner(controller: camera, onDetect: _scanQrCode)),
      Positioned(
          left: MediaQuery.of(context).size.width / 2 - 25,
          bottom: 165,
          child: _flashLightButton()),
      Positioned(
        left: 19,
        bottom: 79,
        child: _myQrCode(),
      ),
      Positioned(
        right: 25,
        bottom: 79,
        child: _album(),
      ),
    ]);
  }
}
