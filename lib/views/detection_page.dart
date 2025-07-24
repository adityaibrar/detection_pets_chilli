import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../constant/theme/theme.dart';
import '../providers/detecition_notifier.dart';
import 'widgets/fuzzy_dialog.dart';

class DetectionPage extends StatefulWidget {
  const DetectionPage({super.key});

  @override
  State<DetectionPage> createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<DetectionViewModel>(context, listen: false);
      viewModel.initialize();
    });
  }

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
        child: Consumer<DetectionViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              spacing: 10.h,
              children: [
                _buildImageDisplay(viewModel),
                if (viewModel.detectionResult.isNotEmpty) ...[
                  _buildDetectionResult(viewModel),
                ],
                _itemMenu(Icons.image, 'Dari Galeri', () {
                  viewModel.pickImage(ImageSource.gallery);
                }),
                _itemMenu(Icons.camera_alt, 'Dari Kamera', () {
                  viewModel.pickImage(ImageSource.camera);
                }),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: Consumer<DetectionViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isChiliLeafDetected && !viewModel.isLoading) {
            return Container(
              padding: EdgeInsets.all(16.r),
              color: Colors.white,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => FuzzyDialog(
                      onDetectionPressed: (symptoms) {
                        viewModel.performFuzzyDetection(symptoms);
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Analisis Gejala Lanjut',
                  style: whiteTextStyle.copyWith(
                    fontWeight: semiBold,
                    fontSize: 18.sp,
                  ),
                ),
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetectionResult(DetectionViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            viewModel.detectionResult,
            style: blackTextStyle.copyWith(fontSize: 18.sp, fontWeight: bold),
          ),
          if (viewModel.confidenceText.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                viewModel.confidenceText,
                style: blackTextStyle.copyWith(fontSize: 16.sp),
              ),
            ),
        ],
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

  Widget _buildImageDisplay(DetectionViewModel detectionViewModel) {
    return detectionViewModel.selectedFile != null
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Image.file(
                  File(detectionViewModel.selectedFile!.path),
                  height: 200.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: -10,
                right: -8,
                child: GestureDetector(
                  onTap: detectionViewModel.deleteImage,
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
