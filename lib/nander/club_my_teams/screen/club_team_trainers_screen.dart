import 'package:flutter/material.dart';

import '../../core/endpoint/api_endpoint.dart';
import '../controller/club_teams_trainer_controller.dart';

class TeamTrainersScreen extends StatefulWidget {
  final String teamId;
  final String teamName;

  const TeamTrainersScreen({super.key, required this.teamId, required this.teamName});

  @override
  State<TeamTrainersScreen> createState() => _TeamTrainersScreenState();
}

class _TeamTrainersScreenState extends State<TeamTrainersScreen> with SingleTickerProviderStateMixin {
  final TeamTrainersController _controller = TeamTrainersController();
  late TabController _tabController;
  int _currentTab = 0; // 0 = My Trainers, 1 = Requests

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _currentTab = _tabController.index);
      }
    });
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.fetchAllData(widget.teamId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A192F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.teamName,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          // ✅ FACEBOOK-STYLE PULL TO REFRESH
          return RefreshIndicator(
            onRefresh: _loadData,
            color: const Color(0xFF3B82F6),
            backgroundColor: const Color(0xFF112240),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // Required for RefreshIndicator
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom Tabs
                  Row(
                    children: [
                      _buildTab("My Trainers", 0),
                      const SizedBox(width: 12),
                      _buildTab("Trainer's Request", 1),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF112240),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E3A5F)),
                    ),
                    child: TextField(
                      onChanged: _controller.updateSearch,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search trainer...',
                        hintStyle: TextStyle(color: Color(0xFF8892B0)),
                        prefixIcon: Icon(Icons.search, color: Color(0xFF8892B0)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Content Based on Tab
                  if (_currentTab == 0) ...[
                    if (_controller.activeTrainers.isEmpty)
                      _buildEmptyState("No trainers found")
                    else
                      ListView.separated(
                        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                        itemCount: _controller.activeTrainers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) => _buildTrainerCard(_controller.activeTrainers[i]),
                      ),
                  ] else ...[
                    if (_controller.requestedTrainers.isEmpty)
                      _buildEmptyState("No pending requests")
                    else
                      ListView.separated(
                        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                        itemCount: _controller.requestedTrainers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) => _buildRequestCard(_controller.requestedTrainers[i]),
                      ),
                  ],

                  const SizedBox(height: 80), // Space for bottom button
                ],
              ),
            ),
          );
        },
      ),
      // Bottom Add Button
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A192F),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
        ),
        child: SizedBox(
          width: double.infinity, height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigate to Find/Add Trainer Screen
              debugPrint("Navigate to find trainers for team: ${widget.teamId}");
            },
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            label: const Text('Add New Trainer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _currentTab == index;
    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(title,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF8892B0),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            )),
      ),
    );
  }

  Widget _buildTrainerCard(TrainerModel trainer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF112240),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24, backgroundColor: const Color(0xFF1E3A5F),
            backgroundImage: trainer.profile != null
                ? NetworkImage('${ApiEndpoint.host}${trainer.profile}') : null,
            child: trainer.profile == null ? const Icon(Icons.person, color: Colors.white54) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trainer.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(trainer.email, style: const TextStyle(color: Color(0xFF8892B0), fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(TrainerModel trainer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF112240),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trainer.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(trainer.email, style: const TextStyle(color: Color(0xFF8892B0), fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Action Buttons or Status Badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: () async {
                    final success = await _controller.handleRequest(trainer.id, 'approve');
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? "Approved!" : "Failed"),
                            backgroundColor: success ? Colors.green : Colors.red));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  child: const Text('Approve', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 36,
                child: OutlinedButton(
                  onPressed: () async {
                    final success = await _controller.handleRequest(trainer.id, 'reject');
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? "Declined" : "Failed"),
                            backgroundColor: success ? Colors.orange : Colors.red));
                  },
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white, side: const BorderSide(color: Color(0xFF1E3A5F)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  child: const Text('Decline', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) => Center(
      child: Padding(padding: const EdgeInsets.only(top: 40),
          child: Text(msg, style: const TextStyle(color: Color(0xFF8892B0), fontSize: 16))));
}