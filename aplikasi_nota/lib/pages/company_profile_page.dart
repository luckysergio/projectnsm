import 'package:flutter/material.dart';
import '../models/company_profile.dart';
import '../repositories/company_profile_repository.dart';

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({super.key});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _ownerCtrl = TextEditingController();
  final _bankAccountCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _socialMediaCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();

  CompanyProfile? _profile;
  final _repo = CompanyProfileRepository();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _repo.getProfile();
    if (profile != null) {
      setState(() {
        _profile = profile;
        _nameCtrl.text = profile.name;
        _ownerCtrl.text = profile.owner;
        _bankAccountCtrl.text = profile.bankAccount;
        _addressCtrl.text = profile.address;
        _phoneCtrl.text = profile.phone;
        _emailCtrl.text = profile.email;
        _socialMediaCtrl.text = profile.socialMedia;
        _websiteCtrl.text = profile.website;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final profile = CompanyProfile(
      id: _profile?.id,
      name: _nameCtrl.text,
      owner: _ownerCtrl.text,
      bankAccount: _bankAccountCtrl.text,
      address: _addressCtrl.text,
      phone: _phoneCtrl.text,
      email: _emailCtrl.text,
      socialMedia: _socialMediaCtrl.text,
      website: _websiteCtrl.text,
    );

    try {
      if (_profile == null) {
        await _repo.insertProfile(profile);
      } else {
        await _repo.updateProfile(profile);
      }

      // Refresh data
      await _loadProfile();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data berhasil disimpan')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ownerCtrl.dispose();
    _bankAccountCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _socialMediaCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        validator:
            validator ??
            (v) {
              if (v == null || v.trim().isEmpty) return 'Wajib diisi';
              return null;
            },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Perusahaan'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informasi Perusahaan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTextField(label: 'Nama Perusahaan', controller: _nameCtrl),
              _buildTextField(label: 'Pemilik', controller: _ownerCtrl),
              _buildTextField(
                label: 'No. Rekening',
                controller: _bankAccountCtrl,
              ),
              _buildTextField(label: 'Alamat', controller: _addressCtrl),
              _buildTextField(
                label: 'No. Telepon',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                label: 'Email',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                label: 'Sosial Media',
                controller: _socialMediaCtrl,
              ),
              _buildTextField(
                label: 'Website / Link Company Profile',
                controller: _websiteCtrl,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon:
                      _isSaving
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Menyimpan...' : 'SIMPAN PROFIL'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveProfile,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
