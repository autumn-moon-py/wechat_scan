import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_v3/image_gallery_saver.dart';

class TranResultPage extends StatefulWidget {
  final Uint8List old;
  final Uint8List tran;
  final String orientation;
  const TranResultPage(this.old, this.tran, this.orientation, {super.key});

  @override
  TranResultPageState createState() => TranResultPageState();
}

class TranResultPageState extends State<TranResultPage> {
  ValueNotifier<bool> show = ValueNotifier<bool>(false);
  late Matrix4 m4;
  double z = 0;

  @override
  void initState() {
    m4 = Matrix4.identity();
    if (widget.orientation == 'up') m4 = Matrix4.rotationZ(0);
    if (widget.orientation == 'left') m4 = Matrix4.rotationZ(-1.6);
    if (widget.orientation == 'right') m4 = Matrix4.rotationZ(1.6);
    if (widget.orientation == 'down') m4 = Matrix4.rotationZ(3.1);
    super.initState();
  }

  //返回
  Widget backButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_circle_left, color: Colors.white, size: 25),
      onPressed: () => Get.back(),
    );
  }

  //旧图片
  Widget oldImage() {
    return ValueListenableBuilder(
        valueListenable: show,
        builder: (context, value, child) {
          if (value) {
            return Transform(
                transform: m4,
                child: Image.memory(
                  widget.old,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(error.toString(),
                        style: const TextStyle(color: Colors.white));
                  },
                ));
          }
          return const SizedBox();
        });
  }

  //翻译后的图片
  Widget tranImage() {
    return Transform(
        transform: m4, child: Image.memory(widget.tran, fit: BoxFit.fill));
  }

  //展示旧图片
  Widget showOldImage() {
    return IconButton(
        icon: const Icon(Icons.g_translate_rounded,
            color: Colors.white, size: 35),
        onPressed: () {
          show.value = !show.value;
        });
  }

  //保存翻译图片
  Widget saveImageButton() {
    return IconButton(
      icon: const Icon(Icons.download, color: Colors.white, size: 35),
      onPressed: () async {
        final result = await ImageGallerySaver.saveImage(widget.tran,
            name: '翻译', quality: 100);
        if (result['isSuccess']) {
          EasyLoading.showToast('已保存',
              toastPosition: EasyLoadingToastPosition.bottom);
        } else {
          EasyLoading.showError('保存失败');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(color: Colors.black),
      Center(child: tranImage()),
      Center(child: oldImage()),
      Positioned(top: 25, left: 5, child: backButton()),
      Positioned(left: 85, bottom: 70, child: showOldImage()),
      Positioned(right: 88, bottom: 70, child: saveImageButton()),
    ]);
  }
}
