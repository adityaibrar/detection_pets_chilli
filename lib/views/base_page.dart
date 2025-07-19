import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../constant/theme/theme.dart';
import '../providers/history_notifier.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  int _current = 0;
  final GlobalKey<RefreshIndicatorState> _refreshIndicator =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _fetchHistory();
    });
  }

  Future<void> _fetchHistory() async {
    await context.read<HistoryViewModel>().loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.person, color: whiteColor),
            Image.asset('assets/images/ic_appbar.png', height: 30.h),
            Icon(Icons.notifications, color: whiteColor),
          ],
        ),
      ),
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        color: primaryColor,
        key: _refreshIndicator,
        onRefresh: _fetchHistory,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
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
                      color: _current == index ? secondaryColor : primaryColor,
                    ),
                  );
                }),
              ),
              SizedBox(height: 10.h),
              Consumer<HistoryViewModel>(
                builder: (context, historyViewModel, child) {
                  if (historyViewModel.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (historyViewModel.historyList.isEmpty) {
                    return Container(
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
                    );
                  }
                  return SizedBox(
                    height: 300.h,
                    child: ListView.separated(
                      itemCount: historyViewModel.historyList.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 10.h);
                      },
                      itemBuilder: (context, index) {
                        final history = historyViewModel.historyList[index];
                        return Dismissible(
                          key: Key(history.id.toString()),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: whiteColor,
                                title: Text(
                                  "Konfirmasi",
                                  style: blackTextStyle.copyWith(
                                    fontWeight: bold,
                                    fontSize: 24.sp,
                                  ),
                                ),
                                content: Text(
                                  "Yakin ingin menghapus item ini?",
                                  style: blackTextStyle.copyWith(
                                    fontSize: 16.sp,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(
                                      "Batal",
                                      style: primaryTextStyle.copyWith(
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text("Hapus", style: whiteTextStyle),
                                  ),
                                ],
                              ),
                            );
                          },
                          background: Container(),
                          secondaryBackground: Container(
                            margin: EdgeInsets.only(bottom: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20.w),
                            child: Icon(Icons.delete, color: whiteColor),
                          ),
                          onDismissed: (_) =>
                              historyViewModel.deleteDetection(history.id!),
                          child: Container(
                            height: 80.h,
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Center(
                              child: ListTile(
                                leading: Image.file(
                                  File(history.imagePath),
                                  height: 50.h,
                                  width: 50.w,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(
                                  history.pestName,
                                  style: blackTextStyle.copyWith(
                                    fontSize: 18.sp,
                                    fontWeight: semiBold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${history.date.day}/${history.date.month}/${history.date.year}',
                                  style: blackTextStyle.copyWith(
                                    fontSize: 14.sp,
                                    fontWeight: medium,
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: history.severity == "Ringan"
                                            ? primaryColor.withValues(
                                                alpha: 0.3,
                                              )
                                            : history.severity == "Sedang"
                                            ? Colors.orange
                                            : Colors.red,
                                        borderRadius: BorderRadius.circular(
                                          5.r,
                                        ),
                                      ),
                                      child: Text(
                                        history.severity,
                                        style: TextStyle(
                                          color: history.severity == "Ringan"
                                              ? Colors.green
                                              : Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${history.confidence.toStringAsFixed(2)}%',
                                      style: blackTextStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
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
