import 'package:flutter/material.dart';
import '../controller/add_trainer_controller.dart';

class ClubAddTrainerScreen extends StatefulWidget {
  final String teamId;

  const ClubAddTrainerScreen({super.key, required this.teamId});

  @override
  State<ClubAddTrainerScreen> createState() => _ClubAddTrainerScreenState();
}

class _ClubAddTrainerScreenState extends State<ClubAddTrainerScreen> {
  final ClubAddTrainerController _controller = ClubAddTrainerController();
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  bool _isInviteMode = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // ✅ AUTO FETCH ON SCREEN LOAD
    _controller.initSearch(widget.teamId);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRequest(AvailableTrainerModel trainer) async {
    setState(() => _isSubmitting = true);
    try {
      await _controller.sendRequest(
        teamId: widget.teamId,
        trainerId: trainer.id,
        trainerName: trainer.name,
        email: trainer.email,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request sent!"), backgroundColor: Colors.green));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleInvite() async {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fill all fields"), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _controller.inviteNewTrainer(
        teamId: widget.teamId,
        trainerName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invitation sent!"), backgroundColor: Colors.green));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
        title: Text(_isInviteMode ? 'Invite Trainer' : 'Add Trainer',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_isInviteMode) return _buildInviteForm();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF112240),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E3A5F)),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _controller.updateSearch, // ✅ Just filter locally now
                    autofocus: true,
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
                const SizedBox(height: 16), // ✅ Reduced from 20

                // Loading State
                if (_controller.isLoading)
                  const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
                  )

                // Results Found
                else if (_controller.hasSearched && _controller.availableTrainers.isNotEmpty) ...[
                  ListView.separated(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    itemCount: _controller.availableTrainers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8), // ✅ Reduced gap
                    itemBuilder: (ctx, i) {
                      final trainer = _controller.availableTrainers[i];
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
                                  Text(trainer.name,
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(trainer.email,
                                      style: const TextStyle(color: Color(0xFF8892B0), fontSize: 14)),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 36,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : () => _handleRequest(trainer),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                                child: const Text('Request'),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24), // ✅ Reduced from 30
                  _buildInviteSection(),
                ]

                // No Results / Empty
                else if (_controller.hasSearched && _controller.availableTrainers.isEmpty) ...[
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          const Text('Trainer not found!',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('Search again or invite manually',
                              style: TextStyle(color: Color(0xFF8892B0), fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInviteSection(),
                  ]

                  // Initial Loading Placeholder (before auto-fetch completes)
                  else
                    const SizedBox(height: 40),

                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInviteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Can't Find Your Trainer?",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text("Search again with correct name or email",
            style: TextStyle(color: Color(0xFF8892B0), fontSize: 14)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton(
            onPressed: () => setState(() => _isInviteMode = true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Invite the Trainer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildInviteForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trainer Name', style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 8),
          _buildInputField(_nameCtrl, 'Full Name'),
          const SizedBox(height: 20),
          const Text('Trainer Email', style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 8),
          _buildInputField(_emailCtrl, 'Enter Trainer Email', isEmail: true),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleInvite,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController ctrl, String hint, {bool isEmail = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF112240),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: Color(0xFF8892B0)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}