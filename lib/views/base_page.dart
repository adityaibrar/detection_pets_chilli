import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_router/go_router.dart';
import '../constant/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  int _current = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.person),
            Image.asset('assets/images/ic_appbar.png', height: 30.h),
            Icon(Icons.notifications),
          ],
        ),
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 177.h,
                enlargeCenterPage: true,
                autoPlay: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 1,
                onPageChanged: (context, reason) {
                  setState(() {
                    _current = context;
                  });
                },
              ),
              items:
                  [
                    'assets/images/banner_1.png',
                    'assets/images/banner_2.png',
                    'assets/images/banner_3.png',
                  ].map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.asset(i, fit: BoxFit.cover),
                        );
                      },
                    );
                  }).toList(),
            ),
            SizedBox(height: 6.h),
            // Indikator titik
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(3, (index) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 2.0,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == index ? secondaryColor : Colors.grey,
                  ),
                );
              }),
            ),
            SizedBox(height: 10.h),
            Container(
              height: 100.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(20.h),
              ),
              child: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plantum',
                      style: primaryTextStyle.copyWith(
                        color: secondaryColor,
                        fontSize: 12.sp,
                        fontWeight: bold,
                      ),
                    ),
                    Text(
                      'Please, Click the Scan Button',
                      style: primaryTextStyle.copyWith(
                        color: secondaryColor,
                        fontSize: 18.sp,
                        fontWeight: bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          context.go('/base-page/detection-page');
        },
        child: Icon(Icons.scanner_rounded, color: whiteColor),
      ),
    );
  }
}
