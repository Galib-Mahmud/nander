import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/club_my_teams_controller.dart';
import '../../team/controller/team_model.dart';

class ClubAddNewTeamScreen extends StatefulWidget {
  final TeamModel? teamToEdit; // Null = Add | Not Null = Edit

  const ClubAddNewTeamScreen({super.key, this.teamToEdit});

  @override
  State<ClubAddNewTeamScreen> createState() => _ClubAddNewTeamScreenState();
}

class _ClubAddNewTeamScreenState extends State<ClubAddNewTeamScreen> {
  final ClubMyTeamsController _controller = ClubMyTeamsController();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _addressCtrl;

  File? _selectedImage;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Pre-fill fields only if we are editing an existing team
    _nameCtrl = TextEditingController(text: widget.teamToEdit?.name ?? '');
    _bioCtrl = TextEditingController(text: widget.teamToEdit?.bio ?? '');
    _addressCtrl = TextEditingController(text: widget.teamToEdit?.address ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  Future<void> _saveTeam() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final isEditing = widget.teamToEdit != null;
      bool success = false;

      if (isEditing) {
        // ✏️ EDIT MODE -> PATCH /team/update
        success = await _controller.updateTeam(
          id: widget.teamToEdit!.id,
          name: _nameCtrl.text.trim(),
          bio: _bioCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          imageFile: _selectedImage,
        );
      } else {
        // ➕ ADD MODE -> POST /team/create
        success = await _controller.createTeam(
          name: _nameCtrl.text.trim(),
          bio: _bioCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          imageFile: _selectedImage,
        );
      }

      if (!mounted) return;
      if (success) Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.teamToEdit != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A192F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Team'.tr : 'Add New Team'.tr,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Team Name'.tr),
              _buildTextField(_nameCtrl, 'Full Team name'.tr,
                  validator: (v) => v!.isEmpty ? 'Team name is required'.tr : null),
              const SizedBox(height: 20),

              _buildLabel('Team Bio'.tr),
              _buildTextField(_bioCtrl, 'Enter Team Bio....'.tr),
              const SizedBox(height: 20),

              _buildLabel('Address'.tr),
              _buildTextField(_addressCtrl, 'Type here.....'.tr),
              const SizedBox(height: 20),

              _buildLabel('Upload Image'.tr),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 56, width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF112240),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E3A5F)),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    children: [
                      Icon(Icons.image_outlined,
                          color: _selectedImage != null ? Colors.white : const Color(0xFF8892B0)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedImage?.path.split('/').last ?? 'Choose your image'.tr,
                          style: TextStyle(
                              color: _selectedImage != null ? Colors.white : const Color(0xFF8892B0)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveTeam,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 24, height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(isEditing ? 'Update Team'.tr : 'Save Team'.tr,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)));

  Widget _buildTextField(TextEditingController ctrl, String hint,
      {String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF8892B0)),
        filled: true,
        fillColor: const Color(0xFF112240),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E3A5F))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3B82F6))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}