import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_v3/image_gallery_saver.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';

class MyQrCodePage extends StatefulWidget {
  final MobileScannerController camera;
  const MyQrCodePage(this.camera, {super.key});

  @override
  State<MyQrCodePage> createState() => _MyQrCodePageState();
}

class _MyQrCodePageState extends State<MyQrCodePage> {
  final _boundaryKey = GlobalKey();
  final _name = '秋月';
  final _city = '广东广州';
  final _avater = 'assets/me.jpg';
  int _salt = 0;

  //弹出底部抽屉
  void _bottomSheet() {
    Get.bottomSheet(Wrap(
      children: [
        GestureDetector(
          onTap: () {
            Get.back();
            _salt = Random().nextInt(100);
            setState(() {});
          },
          child: Container(
            width: double.infinity,
            color: Colors.white,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Text('重置二维码', style: TextStyle(fontSize: 18)),
          ),
        ),
        Container(color: Colors.grey.shade100, height: 10),
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: double.infinity,
            color: Colors.white,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Text('取消', style: TextStyle(fontSize: 18)),
          ),
        )
      ],
    ));
  }

  //扫一扫
  void _scan() {
    Get.back();
    widget.camera.start();
  }

  //换个样式
  void _changeStyle() => EasyLoading.showToast('未实现');

  //保存图片
  Future<void> _saveImage() async {
    final boundary = _boundaryKey.currentContext?.findRenderObject();
    if (boundary != null && boundary is RenderRepaintBoundary) {
      final image = await boundary.toImage(pixelRatio: 2);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData != null) {
        Uint8List imageData = byteData.buffer.asUint8List();
        final result = await ImageGallerySaver.saveImage(imageData,
            name: '我的二维码', quality: 100);
        if (result['isSuccess']) {
          EasyLoading.showToast('已保存',
              toastPosition: EasyLoadingToastPosition.bottom);
        } else {
          EasyLoading.showError('保存失败');
        }
      }
    }
  }

  //关闭按钮
  Widget _backButton() {
    return GestureDetector(
        onTap: () {
          Get.back();
          widget.camera.start();
        },
        child: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black));
  }

  //更多菜单
  Widget _moreButton() {
    return GestureDetector(
        onTap: _bottomSheet,
        child: const Icon(Icons.more_horiz, size: 25, color: Colors.black));
  }

  //我的信息
  Widget _myInfo() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        child: Image.asset(_avater, width: 44, height: 44),
      ),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          _name,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
        ),
        const SizedBox(height: 3),
        Text(
          _city,
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
      ]),
      const SizedBox(width: 135),
    ]);
  }

  //我的二维码
  Widget _myQrCode() {
    return QrImageView(
      data: _name + _city + _salt.toString(),
      version: QrVersions.auto,
      padding: const EdgeInsets.all(0),
      embeddedImage: AssetImage(_avater),
      embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(50, 50)),
      size: 200,
    );
  }

  //提示
  Widget _tip() {
    return const Text('扫一扫上面的二维码图案，加我为朋友。',
        style: TextStyle(color: Colors.black, fontSize: 11));
  }

  //底部按钮
  Widget _bottomButtons() {
    Widget greyLine() => Container(
          width: 1,
          height: 10,
          color: Colors.grey,
          margin: const EdgeInsets.symmetric(horizontal: 10),
        );
    Widget button(String title, Function() onTap) => GestureDetector(
        onTap: onTap,
        child: Text(
          title,
          style: const TextStyle(fontSize: 13, color: Colors.blue),
        ));
    return Row(children: [
      button('扫一扫', _scan),
      greyLine(),
      button('换个样式', _changeStyle),
      greyLine(),
      button('保存图片', _saveImage)
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: Stack(children: [
        RepaintBoundary(
          key: _boundaryKey,
          child: Container(
            color: Colors.white24,
            height: 430,
            margin: const EdgeInsets.only(top: 130),
            padding: const EdgeInsets.only(top: 35),
            child: Column(children: [
              _myInfo(),
              const SizedBox(height: 45),
              _myQrCode(),
              const SizedBox(height: 40),
              _tip(),
            ]),
          ),
        ),
        Positioned(top: 45, left: 13, child: _backButton()),
        Positioned(top: 41, right: 12, child: _moreButton()),
        Positioned(left: 87, bottom: 58, child: _bottomButtons()),
      ]),
    );
  }
}
