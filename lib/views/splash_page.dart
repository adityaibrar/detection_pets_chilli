import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../constant/theme/theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      context.go('/starter');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 80),
          Center(child: Image.asset('assets/images/logo.png', height: 202.h)),
          SizedBox(height: 200),
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  right: 80,
                  child: Image.asset('assets/images/leaf_2.png', height: 300),
                ),
                Positioned(
                  left: 230,
                  child: Image.asset('assets/images/leaf_1.png', height: 300),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
