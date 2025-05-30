import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PengajuanPerawatanPage extends StatefulWidget {
  const PengajuanPerawatanPage({super.key});

  @override
  State<PengajuanPerawatanPage> createState() => _PengajuanPerawatanPageState();
}

class _PengajuanPerawatanPageState extends State<PengajuanPerawatanPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _token;

  int? _selectedAlatId;
  DateTime? _selectedDate;
  String _operatorName = "";
  String _catatan = "";

  List<Map<String, dynamic>> _alatTersedia = [];

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) _fetchAlatTersedia();
  }

  Future<void> _fetchAlatTersedia() async {
    const String apiUrl = "http://192.168.1.104:8000/api/inventori-tersedia";
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $_token"},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _alatTersedia = data.cast<Map<String, dynamic>>();
          if (_alatTersedia.isNotEmpty) {
            _selectedAlatId = _alatTersedia.first['id'];
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching alat: $e");
    }
  }

  Future<void> _submitPengajuan() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.104:8000/api/perawatan"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
        body: jsonEncode({
          "inventori_id": _selectedAlatId,
          "tanggal_mulai": _selectedDate?.toIso8601String(),
          "operator_name": _operatorName,
          "catatan": _catatan,
        }),
      );

      if (response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        _showErrorDialog("Terjadi kesalahan saat mengajukan perawatan!");
      }
    } catch (e) {
      _showErrorDialog("Gagal terhubung ke server! Periksa koneksi Anda.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi Pengajuan"),
          content: const Text(
            "Apakah Anda yakin ingin mengajukan perawatan ini?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _submitPengajuan();
              },
              child: const Text("Ya, Ajukan"),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 80, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  "Pengajuan Berhasil!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Pengajuan perawatan Anda telah berhasil dikirim.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Gagal Mengajukan"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Pengajuan Perawatan"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildDropdownAlat(),
                    _buildDatePicker(),
                    _buildTextField(
                      "Nama Operator",
                      (value) => _operatorName = value,
                    ),
                    _buildTextField(
                      "Catatan",
                      (value) => _catatan = value,
                      isMultiline: true,
                    ),
                  ],
                ),
              ),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _showConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Ajukan Perawatan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownAlat() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<int>(
        value: _selectedAlatId,
        decoration: _inputDecoration("Pilih Alat"),
        items:
            _alatTersedia
                .map(
                  (alat) => DropdownMenuItem<int>(
                    value: alat["id"],
                    child: Text(alat["nama_alat"]),
                  ),
                )
                .toList(),
        onChanged: (value) => setState(() => _selectedAlatId = value),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(
          _selectedDate == null
              ? "Pilih Tanggal Mulai"
              : "Tanggal: ${_selectedDate!.toLocal().toString().split(' ')[0]}",
          style: const TextStyle(fontSize: 16),
        ),
        tileColor: Colors.blue.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        trailing: const Icon(Icons.calendar_today, color: Colors.blue),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() => _selectedDate = pickedDate);
          }
        },
      ),
    );
  }

  Widget _buildTextField(
    String label,
    Function(String) onChanged, {
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        maxLines: isMultiline ? 3 : 1,
        decoration: _inputDecoration(label),
        validator: (value) => value!.isEmpty ? "Harap isi $label" : null,
        onChanged: onChanged,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.blue.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
