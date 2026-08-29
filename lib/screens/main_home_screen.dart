import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_app/controllers/navigation_controller.dart';
import 'package:hrms_app/screens/home_screen.dart';
import 'package:hrms_app/screens/attendance_screen.dart';
import 'package:hrms_app/screens/leave_screen.dart';
import 'package:hrms_app/screens/salary_screen.dart';
import 'package:hrms_app/screens/profile_screen.dart';

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.put(NavigationController());

    final screens = <Widget>[
      const HomeScreen(),
      const AttendanceScreen(),
      const LeaveScreen(),
      const SalaryScreen(),
      const ProfileScreen(),
    ];

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Obx(() => screens[navController.selectedIndex.value]),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            currentIndex: navController.selectedIndex.value,
            onTap: navController.changeTab,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.access_time),
                label: 'Attendance',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event_note),
                label: 'Leave',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.description),
                label: 'Salary',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
