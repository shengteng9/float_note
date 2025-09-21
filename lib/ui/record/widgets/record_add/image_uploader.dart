import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:float_note/ui/record/view_model/record_form_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageUploader extends ConsumerWidget {
  const ImageUploader({super.key});

  // 显示提示弹窗
  void showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('提示', textAlign: TextAlign.center),
          content: Text(message, textAlign: TextAlign.center),
          actionsPadding: EdgeInsets.all(0),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: Size(double.infinity, 60), // 宽度无限延伸，高度50
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 显示全屏图片
  void showFullScreenImage(BuildContext context, WidgetRef ref) {
    final recordLocalImageFile = ref.read(recordFormNotifierProvider.select((state)=>state.recordLocalImageFile));
    
    if (recordLocalImageFile != null) {
      showDialog(
        context: context,
        barrierColor: Colors.black,
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: Colors.black,
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Image.file(
                  recordLocalImageFile,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          );
        },
      );
    }
  }

  Widget imagePreview(BuildContext context,File? recordLocalImageFile,WidgetRef ref) {
    if (recordLocalImageFile != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
    GestureDetector(
      onTap: () => showFullScreenImage(context, ref), // 点击放大
      child: Image.file(
        recordLocalImageFile, // 你的本地图片文件
        fit: BoxFit.cover,
        width: 130,
        height: 130,
      ),
    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 重新选择按钮
          IconButton(
            icon: Icon(Icons.close_outlined, size: 20, color: Theme.of(context).colorScheme.primary),
            onPressed: () => {
              //todo delete image
              print('delete...'),
              ref.read(recordFormNotifierProvider.notifier).deleteImage(),
            }
          ),
        ],
      ),
        ],
      );
    }
    return Container();
  }

  Widget imageUpdateView(BuildContext context,Function pickImage, File? recordLocalImageFile ) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () async {
              await pickImage(ImageSource.gallery, (message) => showAlertDialog(context, message));
            },
            icon: Icon(
              Icons.add_outlined,
              size: 50,
              //color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text('上传图片', style: TextStyle(fontSize: 12)),

          Text(recordLocalImageFile?.path ?? '', style: TextStyle(fontSize: 12)),
        ],
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pickImage =  ref.read(recordFormNotifierProvider.notifier).pickImage;
    final recordLocalImageFile = ref.watch(recordFormNotifierProvider.select((state)=>state.recordLocalImageFile));
    return Center(
      child: recordLocalImageFile == null 
        ? imageUpdateView(context, pickImage, recordLocalImageFile) 
        : imagePreview(context, recordLocalImageFile, ref),
    );
  }
}
