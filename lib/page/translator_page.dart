import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
// ignore: library_prefixes
import 'package:image/image.dart' as Img;
import '../main.dart';
import 'tran_result_page.dart';

class TranslatorPage extends StatefulWidget {
  const TranslatorPage({super.key});

  @override
  State<TranslatorPage> createState() => _TranslatorPageState();
}

class _TranslatorPageState extends State<TranslatorPage> {
  late CameraController _controller;
  final ValueNotifier<bool> _connect = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _load = ValueNotifier<bool>(false);
  final appKey = '';
  final secret = '';

  @override
  void initState() {
    super.initState();
    checkConnect();
  }

  @override
  void dispose() async {
    _controller.dispose();
    super.dispose();
  }

  //初始化相机
  Future<void> initCamera() async {
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.max,
    );
    await _controller.initialize();
  }

  //检查网络
  Future<void> checkConnect() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _connect.value = false;
    } else {
      _connect.value = true;
    }
  }

  ///有道云图片翻译
  ///https://ai.youdao.com/console/#/service-singleton/image-translation
  Future<void> _tranImage(Uint8List image) async {
    if (appKey.isEmpty || secret.isEmpty) {
      throw 'appKey或secret不能为空';
    }
    var url = 'https://openapi.youdao.com/ocrtransapi';
    var salt = '62C7AC5817773C3C3B879340C2A3EB4C'; //任意UUID
    var q = base64Encode(image);
    var sign = _toMD5(appKey, q, salt, secret);
    var body = {
      "type": "1",
      "q": q,
      "from": "en",
      "to": "zh-CHS",
      "appKey": appKey,
      "salt": salt,
      "sign": sign,
      "render": "1"
    };
    var response = await http.post(Uri.parse(url), body: body);
    var result = jsonDecode(response.body);
    if (result['errorCode'] == '0') {
      var tranImage = base64Decode(result['render_image']);
      var orientation = result['orientation'];
      Get.to(() => TranResultPage(image, tranImage, orientation));
      _load.value = false;
      _controller.resumePreview();
    } else {
      //https://ai.youdao.com/DOCSIRMA/html/trans/api/tpfy/index.html
      EasyLoading.showError('错误代码: ${result['errorCode']}');
    }
  }

  //MD5签名
  String _toMD5(appid, q, salt, appKey) {
    var sign = appid + q + salt + appKey;
    return md5.convert(utf8.encode(sign)).toString();
  }

  //压缩图片
  Future<File> _compressImage(String filePath, int quality) async {
    File file = File(filePath);
    Uint8List bytes = await file.readAsBytes();
    final image = Img.decodeImage(bytes);
    Uint8List compressedImage = Img.encodeJpg(image!, quality: quality);
    File compressedFile = File(
        '${filePath.substring(0, filePath.lastIndexOf('.'))}-compressed.jpg');
    await compressedFile.writeAsBytes(compressedImage);
    return compressedFile;
  }

  //翻译相机图片
  Future<void> _scanCameraImage() async {
    XFile file = await _controller.takePicture();
    File compressImage = await _compressImage(file.path, 80);
    Uint8List image = await compressImage.readAsBytes();
    _tranImage(image);
  }

  //翻译相册图片
  Future<void> _scanLocalImage() async {
    List<AssetEntity>? image = await AssetPicker.pickAssets(
      context,
      pickerConfig: const AssetPickerConfig(
          maxAssets: 1,
          specialPickerType: SpecialPickerType.noPreview,
          requestType: RequestType.image),
    );
    try {
      late File file;
      await image![0].file.then((value) => file = value!);
      _tranImage(file.readAsBytesSync());
    } catch (_) {}
  }

  //拍照按钮
  Widget _takePhotoButton() {
    clipOvalContainer(double width, double height, Color color) => ClipOval(
          child: Container(
            color: color,
            width: width,
            height: height,
          ),
        );
    return ValueListenableBuilder(
      valueListenable: _connect,
      builder: (context, value, child) {
        if (value) {
          return GestureDetector(
            onTap: _scanCameraImage,
            child: SizedBox(
              width: 65,
              height: 65,
              child: Stack(
                children: [
                  clipOvalContainer(65, 65, Colors.white70),
                  Center(
                    child: clipOvalContainer(45, 45, Colors.white),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  //相册
  Widget _album() {
    return GestureDetector(
      onTap: _scanLocalImage,
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
  Widget _cameraView() {
    return FutureBuilder(
      future: initCamera(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SizedBox(
              height: double.infinity, child: CameraPreview(_controller));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(color: Colors.black),
      _cameraView(),
      ValueListenableBuilder(
        valueListenable: _load,
        builder: (context, value, child) {
          if (value) return const Center(child: CircularProgressIndicator());
          return const SizedBox();
        },
      ),
      Positioned(
          left: MediaQuery.of(context).size.width / 2 - 33,
          bottom: 90,
          child: _takePhotoButton()),
      Positioned(
        right: 25,
        bottom: 79,
        child: _album(),
      ),
    ]);
  }
}
