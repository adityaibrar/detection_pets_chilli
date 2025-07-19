import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../constant/theme/theme.dart';

class StarterPage extends StatefulWidget {
  const StarterPage({super.key});

  @override
  State<StarterPage> createState() => _StarterPageState();
}

class _StarterPageState extends State<StarterPage> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  // ignore: unused_field
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Image.asset('assets/images/logo_header.png', height: 35),
        backgroundColor: whiteColor,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: CarouselSlider(
        items: [
          _buildFirstPage(() {
            _carouselController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          }),
          _buildSecondPage(() {
            context.go('/base-page');
          }),
        ],
        carouselController: _carouselController,
        options: CarouselOptions(
          height: double.infinity,
          enlargeCenterPage: true,
          enableInfiniteScroll: false,
          viewportFraction: 1.0,
          onPageChanged: (index, reason) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildFirstPage(VoidCallback onNext) {
    return Padding(
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Image.asset('assets/images/plant.png', height: 400)),
          SizedBox(height: 10.h),
          Container(
            height: 10.h,
            width: 80.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(colors: [secondaryColor, primaryColor]),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Scan to discover',
            style: primaryTextStyle.copyWith(fontSize: 20, fontWeight: bold),
          ),
          Text(
            'Open up a world of possibilities',
            style: primaryTextStyle.copyWith(fontSize: 18),
          ),
          SizedBox(height: 150.h),
          GestureDetector(
            onTap: onNext,
            child: Container(
              height: 60.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [secondaryColor, primaryColor],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  'Next',
                  style: whiteTextStyle.copyWith(
                    fontSize: 18.sp,
                    fontWeight: medium,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondPage(VoidCallback onStartEnjoy) {
    return Padding(
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset('assets/images/person_plan.png', height: 400),
          ),
          SizedBox(height: 10.h),
          Container(
            height: 10.h,
            width: 80.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(colors: [secondaryColor, primaryColor]),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Welcome to Plantum',
            style: primaryTextStyle.copyWith(fontSize: 20, fontWeight: bold),
          ),
          Text(
            'The plant lovers companion',
            style: primaryTextStyle.copyWith(fontSize: 18),
          ),
          SizedBox(height: 150.h),
          GestureDetector(
            onTap: onStartEnjoy,
            child: Container(
              height: 60.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [secondaryColor, primaryColor],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  'Start Enjoying',
                  style: whiteTextStyle.copyWith(
                    fontSize: 18.sp,
                    fontWeight: medium,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
