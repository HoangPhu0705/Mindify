import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:frontend/services/functions/EnrollmentService.dart';
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
    final coursesData =
        await enrollmentService.getNumStudentsAndRevenue(userId);

    if (enrollmentData == null || revenueData == null) {
      throw Exception('Failed to fetch data');
    }

    return {
      'enrollment': enrollmentData['totalEnrollments'],
      'revenue': revenueData['totalRevenue'],
      'courses': coursesData,
    };
  }

  void _showMonthYearPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          title: const Text(
            "Select Month and Year",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              style: AppStyles.secondaryButtonStyle,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
          content: SizedBox(
            height: 350,
            width: 300,
            child: SfDateRangePicker(
              view: DateRangePickerView.year,
              selectionMode: DateRangePickerSelectionMode.single,
              monthFormat: 'MMM',
              enableMultiView: false,
              allowViewNavigation: false,
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is DateTime) {
                  setState(() {
                    selectedMonthYear =
                        DateFormat('MM-yyyy').format(args.value);
                    futureData = fetchData(widget.userId);
                  });
                  Navigator.of(context).pop();
                }
              },
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
            icon: const Icon(Icons.calendar_today),
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
            final List<Map<String, dynamic>> courses =
                List<Map<String, dynamic>>.from(snapshot.data!['courses']);
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Column(
                children: [
                  _buildDashboardCard(
                    title: 'Enrollments for $selectedMonthYear',
                    value: totalEnrollments > 1
                        ? '${totalEnrollments.toString()} students'
                        : '${totalEnrollments.toString()} student',
                    icon: Icons.person,
                    backgroundColor: AppColors.blue,
                  ),
                  AppSpacing.mediumVertical,
                  _buildDashboardCard(
                    title: 'Revenue for $selectedMonthYear',
                    value:
                        '${NumberFormat.decimalPattern('vi').format(totalRevenue)} VND',
                    icon: Icons.attach_money,
                    backgroundColor: AppColors.deepSpace,
                  ),
                  AppSpacing.mediumVertical,
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text("Top courses",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  AppSpacing.mediumVertical,
                  Expanded(
                    child: ListView.builder(
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: Colors.transparent,
                          elevation: 0,
                          child: ListTile(
                            title: Text(
                              course['courseName'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis),
                              maxLines: 2,
                            ),
                            subtitle: Text(
                              '${course['students']} students | Revenue: ${NumberFormat.decimalPattern('vi').format(course['revenue'])} VND',
                            ),
                            leading: Image.network(course['thumbnail']),
                          ),
                        );
                      },
                    ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundColor.withOpacity(0.7), backgroundColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.4),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
