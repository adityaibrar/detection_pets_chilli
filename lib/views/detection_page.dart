import 'dart:io';

import 'package:detection_pets_chilli/constant/theme/theme.dart';
import 'package:detection_pets_chilli/providers/image_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class DetectionPage extends StatefulWidget {
  const DetectionPage({super.key});

  @override
  State<DetectionPage> createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Detection pets', style: whiteTextStyle),
        foregroundColor: whiteColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Consumer<ImageNotifier>(
          builder: (context, imageNotifier, child) {
            return Column(
              spacing: 10.h,
              children: [
                _buildImageDisplay(imageNotifier),
                _itemMenu(Icons.image, 'Dari Galeri', () {
                  imageNotifier.selectImage(ImageSource.gallery);
                }),
                _itemMenu(Icons.camera_alt, 'Dari Kamera', () {
                  imageNotifier.selectImage(ImageSource.camera);
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _itemMenu(IconData icon, String title, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
        ),
        child: Padding(
          padding: EdgeInsetsGeometry.all(10),
          child: Row(
            children: [
              Icon(icon, color: whiteColor),
              SizedBox(width: 20.w),
              Text(
                title,
                style: whiteTextStyle.copyWith(
                  fontWeight: semiBold,
                  fontSize: 20.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageDisplay(ImageNotifier imageNotifier) {
    return imageNotifier.selectedImage != null
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Image.file(
                  File(imageNotifier.selectedImage!.path),
                  height: 200.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: -10,
                right: -8,
                child: GestureDetector(
                  onTap: imageNotifier.deleteImage,
                  child: _buildDeleteButton(),
                ),
              ),
            ],
          )
        : Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Container(
                  height: 200.h,
                  width: double.infinity,
                  decoration: BoxDecoration(color: whiteColor),
                  child: Icon(Icons.camera_alt, size: 200.h),
                ),
              ),
            ],
          );
  }

  Widget _buildDeleteButton() {
    return Container(
      height: 40.h,
      width: 40.w,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
      child: Icon(Icons.delete_outlined, color: whiteColor),
    );
  }
}
