import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nander/club/home/screen/schedule_screen.dart';
import 'package:nander/club/home/screen/team_screen.dart';
import '../../../trainer/widget/controller/app_drawer_controller.dart';
import '../../../trainer/widget/screen/custom_drawer.dart';
import 'home_dashboard_screen1.dart';
import 'more_screen.dart';

class MainScreen1 extends StatefulWidget {
  const MainScreen1({super.key, this.initialIndex = 0});

  final int initialIndex;

  static double get navBarHeight => 100.h;

  @override
  State<MainScreen1> createState() => _MainScreen1State();
}

class _MainScreen1State extends State<MainScreen1>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late AnimationController _drawerController;
  late Animation<double> _drawerAnimation;
  bool _isDrawerOpen = false;

  // ✅ Initialize the controller
  final AppDrawerController _appDrawerCtrl = Get.put(AppDrawerController());

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _drawerAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _drawerController, curve: Curves.easeOutCubic),
    );

    // ✅ Set the drawer functions
    _appDrawerCtrl.setDrawerFunctions(
      open: _openDrawer,
      close: _closeDrawer,
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  void _openDrawer() {
    _drawerController.forward();
    setState(() {
      _isDrawerOpen = true;
    });
  }

  void _closeDrawer() {
    _drawerController.reverse().then((_) {
      setState(() {
        _isDrawerOpen = false;
      });
    });
  }

  final List<Widget> _pages = [
    const HomeDashboardScreen1(),
    const ScheduleScreen(activeTabIndex: 0),
    const TeamScreen(),
    const MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 8 && !_isDrawerOpen) {
          _openDrawer();
        }
        if (details.delta.dx < -8 && _isDrawerOpen) {
          _closeDrawer();
        }
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: const Color(0xFF0A0E1A),
        body: Stack(
          children: [
            _pages[_currentIndex],

            // Bottom Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNavigationBar(),
            ),

            // Overlay when drawer is open
            if (_isDrawerOpen)
              GestureDetector(
                onTap: _closeDrawer,
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx < -8) {
                    _closeDrawer();
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(
                    0.5 * _drawerController.value,
                  ),
                ),
              ),

            // Drawer
            AnimatedBuilder(
              animation: _drawerAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    _drawerAnimation.value * 280.w,
                    0,
                  ),
                  child: child,
                );
              },
              child: CustomDrawer(
                onClose: _closeDrawer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 72.h,
            decoration: BoxDecoration(
              color: const Color(0xFF0D1424),
              borderRadius: BorderRadius.circular(36.r),
              border: Border.all(
                color: const Color(0xFF2A3550),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                SizedBox(width: 35.h),
                _buildNavItem(
                  iconPath: 'assets/images/home.png',
                  label: 'Home',
                  index: 0,
                ),
                SizedBox(width: 30.h),
                _buildNavItem(
                  iconPath: 'assets/images/schedule.png',
                  label: 'Schedule',
                  index: 1,
                ),
                SizedBox(width: 30.w),
                _buildNavItem(
                  iconPath: 'assets/images/team.png',
                  label: 'Team',
                  index: 2,
                ),
                SizedBox(width: 30.h),
                _buildNavItem(
                  iconPath: 'assets/images/more.png',
                  label: 'More',
                  index: 3,
                ),
              ],
            ),
          ),
          // Positioned(
          //   top: -55.h,
          //   child: GestureDetector(
          //     onTap: () {
          //       Get.toNamed(RouteName.scheduler);
          //     },
          //     child: Image.asset(
          //       'assets/images/group.png',
          //       width: 100.w,
          //       height: 100.h,
          //       fit: BoxFit.contain,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String iconPath,
    required String label,
    required int index,
  }) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() {
        _currentIndex = index;
      }),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 24.w,
              height: 24.h,
              color: isSelected ? Colors.white : const Color(0xFF8B95A5),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF8B95A5),
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}