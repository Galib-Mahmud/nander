import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../routes/route_name.dart';


class PremiumUpgradeScreen extends StatefulWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  State<PremiumUpgradeScreen> createState() => _PremiumUpgradeScreenState();
}

class _PremiumUpgradeScreenState extends State<PremiumUpgradeScreen> {
  String _selectedPlan = 'Lifetime';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050810),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 40.h),

              // ✅ Train Up Logo (Image Asset) with glow effect
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1628),
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4D94FF).withOpacity(0.25),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28.r),
                  child: Image.asset(
                    'assets/images/premimum.png', // ✅ Your logo image
                    width: 120.w,
                    height: 120.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if image not found
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'TU',
                            style: TextStyle(
                              color: Color(0xFF4D94FF),
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Text(
                            'TRAIN UP',
                            style: TextStyle(
                              color: Color(0xFF4D94FF),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: 48.h),

              // Title
              const Text(
                'Upgrade to access premium features',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 32.h),

              // ✅ Quarterly Plan (Star Icon as Image)
              _buildPlanCard(
                planName: 'Quarterly',
                price: '\$4.99',
                description: 'Perfect for short-term users',
                iconPath: 'assets/images/Q.png', // ✅ Image asset
                isSelected: _selectedPlan == 'Quarterly',
                onTap: () => setState(() => _selectedPlan = 'Quarterly'),
              ),

              SizedBox(height: 16.h),

              // ✅ Annually Plan (Trophy Icon as Image)
              _buildPlanCard(
                planName: 'Annually',
                price: '\$13.99',
                description: 'Save more with 12-month access',
                iconPath: 'assets/images/a.png', // ✅ Image asset
                isSelected: _selectedPlan == 'Annually',
                onTap: () => setState(() => _selectedPlan = 'Annually'),
              ),

              SizedBox(height: 16.h),

              // ✅ Lifetime Plan (Crown Icon as Image) with Save badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildPlanCard(
                    planName: 'Lifetime',
                    price: '\$49.99',
                    description: 'Lifetime access with premium benefits',
                    iconPath: 'assets/images/L.png', // ✅ Image asset
                    isSelected: _selectedPlan == 'Lifetime',
                    onTap: () => setState(() => _selectedPlan = 'Lifetime'),
                    isLifetime: true,
                  ),
                  // Save Badge
                  if (_selectedPlan == 'Lifetime')
                    Positioned(
                      top: -12.h,
                      right: 20.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4D94FF),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: const Text(
                          'Save \$9.99',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const Spacer(),

              // Next Button
              GestureDetector(
                onTap: () {
                 Get.toNamed(RouteName.wellcome2);
                },
                child: Container(
                  width: double.infinity,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4D94FF),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: const Center(
                    child: Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String planName,
    required String price,
    required String description,
    required String iconPath, // ✅ Changed from IconData to String (image path)
    required bool isSelected,
    required VoidCallback onTap,
    bool isLifetime = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4D94FF)
                : const Color(0xFF1F2937),
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // ✅ Icon Circle with Image Asset
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2236),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2A3550),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Image.asset(
                  iconPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback icon if image not found
                    return Icon(
                      Icons.star,
                      color: const Color(0xFFFFB800),
                      size: 26.w,
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 16.w),
            // Plan Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    planName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            // Price
            Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}