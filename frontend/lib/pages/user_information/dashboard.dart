import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:intl/intl.dart';
import 'package:d_chart/d_chart.dart';
import 'package:frontend/services/functions/EnrollmentService.dart';

class DashboardPage extends StatefulWidget {
  final String userId;

  DashboardPage({required this.userId});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> futureData;
  final enrollmentService = EnrollmentService();

  @override
  void initState() {
    super.initState();
    futureData = fetchData(widget.userId);
  }

  Future<Map<String, dynamic>> fetchData(String userId) async {
    final enrollmentData = await enrollmentService.getStudentsOfMonth(userId);
    final revenueData = await enrollmentService.getRevenueOfMonth(userId);

    if (enrollmentData == null || revenueData == null) {
      throw Exception('Failed to fetch data');
    }

    DateFormat dateFormat = DateFormat("MM-yyyy");
    DateTime parsedDate = dateFormat.parse(enrollmentData['month']);

    return {
      'enrollment': TimeGroup(
        id: '1',
        data: [
          TimeData(
            domain: parsedDate,
            measure: enrollmentData['totalEnrollments'].toDouble(),
          ),
        ],
      ),
      'revenue': TimeGroup(
        id: '2',
        data: [
          TimeData(
            domain: parsedDate,
            measure: revenueData['totalRevenue'].toDouble(),
          ),
        ],
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enrollment and Revenue Charts')
        ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: MyLoading(
                width: 30,
                height: 30,
                color: AppColors.deepBlue,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No Data Available'));
          } else {
            final enrollmentGroup = snapshot.data!['enrollment'] as TimeGroup;
            final revenueGroup = snapshot.data!['revenue'] as TimeGroup;

            return SingleChildScrollView(
              child: Expanded(
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: DChartBarT(
                        groupList: [enrollmentGroup],
                        domainAxis: DomainAxis(
                          labelFormatterT: (time) =>
                              DateFormat('MM-yyyy').format(time),
                          showLine: true,
                        ),
                        measureAxis: const MeasureAxis(
                          desiredMaxTickCount: 5,
                          desiredTickCount: 5,
                          labelStyle: LabelStyle(fontSize: 16),
                        ),
                        barLabelValue: (group, datum, index) =>
                            datum.measure.toString(),
                        // outsideBarLabelStyle: (group, datum, index) =>
                        //     InsideBarLabelStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 20),
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: DChartBarT(
                        groupList: [revenueGroup],
                        domainAxis: DomainAxis(
                          labelFormatterT: (time) =>
                              DateFormat('MM-yyyy').format(time),
                          showLine: true,
                        ),
                        measureAxis: const MeasureAxis(
                          desiredMaxTickCount: 5,
                          desiredTickCount: 5,
                          labelStyle: LabelStyle(fontSize: 16),
                        ),
                        barLabelValue: (group, datum, index) =>
                            datum.measure.toString(),
                        // outsideBarLabelStyle: (group, datum, index) =>
                        //     InsideBarLabelStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
