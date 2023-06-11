import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_shortcuts/flutter_shortcuts.dart';
import 'package:get/get.dart';

import 'page/wechat_scan_page.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //监听快捷方式
  void _shortcuts() {
    FlutterShortcuts().listenAction((String action) async {
      if (action == 'Scan Page') Get.offAll(() => const WechatScanPage());
    });
  }

  //创建快捷方式
  Future<void> _createShortcut() async {
    FlutterShortcuts flutterShortcuts = FlutterShortcuts();
    flutterShortcuts.initialize(debug: true);
    flutterShortcuts.pushShortcutItem(
      shortcut: const ShortcutItem(
          id: '1',
          action: 'Scan Page',
          icon: 'assets/scan.png',
          shortLabel: '扫一扫'),
    );
  }

  @override
  Widget build(BuildContext context) {
    _createShortcut();
    _shortcuts();
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        builder: EasyLoading.init(),
        home: Scaffold(
            body: Center(
                child: TextButton(
          onPressed: () => Get.to(() => const WechatScanPage()),
          child: const Text('前往WechatScanPage'),
        ))));
  }
}
