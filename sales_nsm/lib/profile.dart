import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sales_nsm/login.dart';
import 'package:sales_nsm/providers/jwt_token_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends ConsumerState<ProfilePage> {
  String? nama;
  String? nik;
  String? email;
  String? jabatan;
  int completedOrdersCount = 0;

  bool isLoading = true;
  bool hasError = false;
  String? token;

  bool showChangePasswordForm = false;
  bool obscureOld = true;
  bool obscureNew = true;
  bool obscureConfirm = true;
  bool isChangingPassword = false;

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTokenAndData();
  }

  Future<void> _loadTokenAndData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (token == null) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      return;
    }

    await Future.wait([fetchProfile(), fetchCompletedOrdersCount()]);
    setState(() => isLoading = false);
  }

  Future<void> fetchProfile() async {
    const String apiUrl = "http://192.168.1.105:8000/api/auth/me";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'] ?? {};
        final karyawan = user['karyawan'] ?? {};
        final role = karyawan['role'] ?? {};

        setState(() {
          nama = karyawan['nama'] ?? "Tidak Ada Nama";
          nik = karyawan['nik']?.toString() ?? "-";
          email = user['email'] ?? "-";
          jabatan = role['jabatan'] ?? "Tidak Ada Jabatan";
        });
      } else {
        setState(() => hasError = true);
      }
    } catch (e) {
      setState(() => hasError = true);
    }
  }

  Future<void> fetchCompletedOrdersCount() async {
    const String apiUrl = "http://192.168.1.105:8000/api/orders/completed";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List orders = data["orders"] ?? [];

        setState(() {
          completedOrdersCount = orders.length;
        });
      } else {
        setState(() => hasError = true);
      }
    } catch (e) {
      setState(() => hasError = true);
    }
  }

  Future<void> _changePassword() async {
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      showErrorDialog("Password baru dan konfirmasi tidak cocok.");
      return;
    }

    setState(() {
      isChangingPassword = true;
    });

    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.105:8000/api/auth/change-password"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: {
          "old_password": oldPassword,
          "new_password": newPassword,
          "new_password_confirmation": confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        showSuccessDialog("Password berhasil diubah.");
        setState(() {
          showChangePasswordForm = false;
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
      } else {
        final error = jsonDecode(response.body);
        showErrorDialog(error['error'] ?? "Gagal mengubah password.");
      }
    } catch (e) {
      showErrorDialog("Terjadi kesalahan saat mengubah password.");
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');

    if (storedToken == null) {
      ref.invalidate(jwtTokenProvider);
      _navigateToLogin();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.105:8000/api/auth/logout"),
        headers: {"Authorization": "Bearer $storedToken"},
      );

      if (response.statusCode == 200) {
        await prefs.clear();
        ref.invalidate(jwtTokenProvider);
        _navigateToLogin();
      } else {
        showErrorDialog("Gagal logout, coba lagi.");
      }
    } catch (e) {
      showErrorDialog("Terjadi kesalahan saat logout.");
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Berhasil"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK", style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
    );
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Gagal"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Tutup", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Profil Karyawan"),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        elevation: 0,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : hasError
              ? const Center(child: Text("Gagal memuat data"))
              : Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  Expanded(child: _buildProfileDetails()),
                  _buildLogoutButton(),
                ],
              ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 50, color: Colors.blueAccent),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nama ?? "Nama tidak tersedia",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                jabatan ?? "Jabatan tidak diketahui",
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildProfileInfo("Nomor Induk Karyawan", nik ?? "-", Icons.badge),
        _buildProfileInfo("Email", email ?? "-", Icons.email),
        _buildProfileInfo(
          "Jumlah Order Selesai",
          completedOrdersCount.toString(),
          Icons.check_circle,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() => showChangePasswordForm = !showChangePasswordForm);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            showChangePasswordForm ? "Batal Ganti Password" : "Ganti Password",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        if (showChangePasswordForm) ...[
          const SizedBox(height: 16),
          _buildPasswordField(
            "Password Lama",
            _oldPasswordController,
            obscureOld,
            () => setState(() => obscureOld = !obscureOld),
          ),
          const SizedBox(height: 10),
          _buildPasswordField(
            "Password Baru",
            _newPasswordController,
            obscureNew,
            () => setState(() => obscureNew = !obscureNew),
          ),
          const SizedBox(height: 10),
          _buildPasswordField(
            "Konfirmasi Password Baru",
            _confirmPasswordController,
            obscureConfirm,
            () => setState(() => obscureConfirm = !obscureConfirm),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isChangingPassword ? null : _changePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              "Simpan Password",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _logout,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
          ),
          child: const Text(
            "Keluar",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String title, String value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(color: Colors.grey)),
        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscure,
    VoidCallback toggleObscure,
  ) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: toggleObscure,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
