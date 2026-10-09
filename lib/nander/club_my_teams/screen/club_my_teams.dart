import 'package:flutter/material.dart';
import '../../core/endpoint/api_endpoint.dart';
import '../../team/controller/team_model.dart';
import '../controller/club_my_teams_controller.dart';
import 'club_add_new_teams.dart';
import 'club_team_trainers_screen.dart';
// Import your new trainers screen here
// import 'team_trainers_screen.dart';

class ClubMyteams extends StatefulWidget {
  const ClubMyteams({super.key});

  @override
  State<ClubMyteams> createState() => _ClubMyteamsState();
}

class _ClubMyteamsState extends State<ClubMyteams> {
  final ClubMyTeamsController _controller = ClubMyTeamsController();

  @override
  void initState() {
    super.initState();
    _controller.fetchTeams();
  }

  /// ✅ FACEBOOK-STYLE REFRESH TRIGGER
  Future<void> _onRefresh() async {
    await _controller.fetchTeams();
  }

  void _showTeamOptions(BuildContext context, TeamModel team) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF112240),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 48, height: 5,
              decoration: BoxDecoration(
                  color: Colors.white24, borderRadius: BorderRadius.circular(3)),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Color(0xFF3B82F6), size: 28),
              title: const Text('Edit Team',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClubAddNewTeamScreen(teamToEdit: team),
                  ),
                );
                if (result == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Team updated successfully!"),
                          backgroundColor: Colors.green));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
              title: const Text('Delete Team',
                  style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w500)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await _controller.deleteTeam(team.id);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Team deleted"), backgroundColor: Colors.green));
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to delete: $e"), backgroundColor: Colors.red));
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A192F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Teams',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      // ✅ WRAP BODY IN REFRESH INDICATOR FOR PULL-TO-REFRESH
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFF3B82F6),
        backgroundColor: const Color(0xFF112240),
        displacement: 40,
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            if (_controller.isLoading && _controller.teams.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
            }

            if (_controller.error != null && _controller.teams.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_controller.error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _controller.fetchTeams, child: const Text("Retry"))
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // Required for RefreshIndicator
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: GridView.builder(
                      shrinkWrap: true, // Required inside SingleChildScrollView
                      physics: const NeverScrollableScrollPhysics(), // Disable inner scroll
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: _controller.teams.length,
                      itemBuilder: (context, index) {
                        final team = _controller.teams[index];
                        // ✅ CACHE-BUSTING FOR IMAGES
                        final imageUrl = team.image != null
                            ? '${ApiEndpoint.resolveImageUrl(team.image)}?t=${DateTime.now().millisecondsSinceEpoch}'
                            : null;

                        return GestureDetector(
                          // ✅ TAP TO NAVIGATE TO TRAINERS SCREEN
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => TeamTrainersScreen(
                                        teamId: team.id,
                                        teamName: team.name
                                    )
                                )
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF112240),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF1E3A5F), width: 1),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundColor: const Color(0xFF1E3A5F),
                                        backgroundImage: imageUrl != null
                                            ? NetworkImage(imageUrl) : null,
                                        child: imageUrl == null
                                            ? const Icon(Icons.groups,
                                            color: Colors.white54, size: 40)
                                            : null,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(team.name,
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                          maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 8),
                                      Text(team.bio ?? "No bio available",
                                          style: const TextStyle(
                                              color: Color(0xFF8892B0), fontSize: 12, height: 1.4),
                                          textAlign: TextAlign.center,
                                          maxLines: 3, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 12, right: 12,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(24),
                                      onTap: () => _showTeamOptions(context, team),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0A192F).withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(24),
                                          border: Border.all(
                                              color: const Color(0xFF1E3A5F), width: 1),
                                        ),
                                        child: const Icon(
                                          Icons.more_vert_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Bottom Add Button with Gradient Fade
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [const Color(0xFF0A192F).withOpacity(0.0), const Color(0xFF0A192F)]),
                    ),
                    child: SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ClubAddNewTeamScreen()),
                          );
                          if (result == true && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Team created successfully!"),
                                    backgroundColor: Colors.green));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0),
                        child: const Text('Add New Team',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // Extra space at bottom
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}