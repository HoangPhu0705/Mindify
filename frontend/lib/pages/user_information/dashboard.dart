import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:frontend/services/functions/EnrollmentService.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DashboardPage extends StatefulWidget {
  final String userId;

  DashboardPage({super.key, required this.userId});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> futureData;
  final enrollmentService = EnrollmentService();
  String selectedMonthYear = DateFormat('MM-yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    futureData = fetchData(widget.userId);
  }

  Future<Map<String, dynamic>> fetchData(String userId) async {
    final parts = selectedMonthYear.split('-');
    final month = int.parse(parts[0]);
    final year = int.parse(parts[1]);
    final data = await enrollmentService.getDashboardData(userId, month, year);
    final enrollmentData = data!['enrollments'];
    final revenueData = data['revenue'];

    if (enrollmentData == null || revenueData == null) {
      throw Exception('Failed to fetch data');
    }

    return {
      'enrollment': enrollmentData['totalEnrollments'],
      'revenue': revenueData['totalRevenue'],
    };
  }

  void _showMonthYearPicker() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Select Month and Year"),
        content: SizedBox(
          height: 350,
          width: 50,
          child: SfDateRangePicker(
            view: DateRangePickerView.year,
            selectionMode: DateRangePickerSelectionMode.single,
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              if (args.value is DateTime) {
                setState(() {
                  selectedMonthYear = DateFormat('MM-yyyy').format(args.value);
                  futureData = fetchData(widget.userId);
                });
              }
              Navigator.of(context).pop();
            },
            showActionButtons: true,
            onCancel: () => Navigator.of(context).pop(),
            onSubmit: (value) => Navigator.of(context).pop(),
          ),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.ghostWhite,
        surfaceTintColor: AppColors.ghostWhite,
        centerTitle: true,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _showMonthYearPicker,
          ),
        ],
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
            final int totalEnrollments = snapshot.data!['enrollment'];
            final int totalRevenue = snapshot.data!['revenue'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: StaggeredGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 2,
                crossAxisSpacing: 1,
                children: [
                  _buildDashboardCard(
                    title: 'Enrollments for $selectedMonthYear',
                    value: totalEnrollments > 1
                        ? '${totalEnrollments.toString()}\nstudents'
                        : '${totalEnrollments.toString()}\nstudent',
                    icon: Icons.person,
                    backgroundColor: AppColors.blue,
                  ),
                  _buildDashboardCard(
                    title: 'Revenue for $selectedMonthYear',
                    value: '${NumberFormat.decimalPattern('vi').format(totalRevenue)} VND',
                    icon: Icons.attach_money,
                    backgroundColor: AppColors.deepSpace,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color backgroundColor,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
