import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nander/trainer/core/endpoint/api_endpoint.dart';
import '../../routes/route_name.dart';
import '../controller/club_controller.dart';

class ClubListScreen extends StatefulWidget {
  const ClubListScreen({super.key});

  @override
  State<ClubListScreen> createState() => _ClubListScreenState();
}

class _ClubListScreenState extends State<ClubListScreen> {
  final ClubController controller = ClubController.to;
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    controller.fetchClubs();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      controller.fetchClubs(search: value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _continue() {
    Get.toNamed(RouteName.login, arguments: {'startTab': 'signup'});
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: List.generate(3, (i) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                const Text('Step 3 of 3', style: TextStyle(color: Colors.white54, fontSize: 14)),
                const SizedBox(height: 24),
                const Text(
                  'Select your Club!',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Pick your club, or skip this step — you can join one later.",
                  style: TextStyle(color: Colors.white54, fontSize: 15),
                ),
                const SizedBox(height: 24),

                // Search bar
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2236),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A3550)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Icon(Icons.search, color: Colors.white38, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: _onSearchChanged,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search clubs...',
                            hintStyle: TextStyle(color: Colors.white38),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ Bounded-height club list — never overflows, never
                // fights the SingleChildScrollView for space.
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: screenHeight * 0.45,
                  ),
                  child: Obx(() {
                    if (controller.isLoading.value && controller.clubs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator(color: Color(0xFF4D94FF))),
                      );
                    }
                    if (controller.clubs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            searchController.text.trim().isNotEmpty ? 'No clubs found' : 'No clubs available yet',
                            style: const TextStyle(color: Colors.white38, fontSize: 14),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: controller.clubs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final club = controller.clubs[index];
                        return Obx(() {
                          final isSelected = controller.selectedClubId.value == club.id;
                          final avatarUrl = ChatEndpoint.resolveImageUrl(club.profile);
                          return GestureDetector(
                            onTap: () => controller.toggleClub(club.id, club.name),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF4D94FF).withOpacity(0.1)
                                    : const Color(0xFF1A2236),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF4D94FF) : const Color(0xFF2A3550),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF2A3550),
                                      image: avatarUrl != null
                                          ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                                          : null,
                                    ),
                                    child: avatarUrl == null
                                        ? Center(
                                      child: Text(
                                        (club.name.isNotEmpty ? club.name[0] : '?').toUpperCase(),
                                        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                                      ),
                                    )
                                        : null,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          club.name,
                                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          (club.bio != null && club.bio!.trim().isNotEmpty)
                                              ? club.bio!
                                              : (club.address ?? 'Club administrator'),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Colors.white54, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle, color: Color(0xFF4D94FF), size: 22),
                                ],
                              ),
                            ),
                          );
                        });
                      },
                    );
                  }),
                ),

                const SizedBox(height: 24),
                // Back / Continue
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF2A3550), width: 1),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Center(
                          child: Text('Back', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: _continue,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4D94FF),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Continue', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}