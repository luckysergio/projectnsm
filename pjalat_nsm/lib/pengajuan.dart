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
  bool _isLoadingData = true;
  String? _token;

  int? _selectedOperatorId;
  final List<DetailPerawatan> _detailPerawatan = [DetailPerawatan()];

  List<Map<String, dynamic>> _operators = [];
  List<Map<String, dynamic>> _alatTersedia = [];

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      if (_token != null) {
        await Future.wait([_fetchOperators(), _fetchAlatTersedia()]);
      } else {
        _showErrorDialog("Token tidak ditemukan. Silakan login kembali.");
      }
    } catch (e) {
      _showErrorDialog("Gagal memuat data awal: $e");
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Future<void> _fetchOperators() async {
    const String apiUrl =
        "http://192.168.1.101:8000/api/karyawan/operator-maintenance";
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $_token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _operators = List<Map<String, dynamic>>.from(data['operators']);
          // Jangan auto-select jika belum ada data
          if (_operators.isNotEmpty && _selectedOperatorId == null) {
            _selectedOperatorId = _operators.first['id'];
          }
        });
        // Debug log
      } else {
        throw Exception("Failed to load operators: ${response.statusCode}");
      }
    } catch (e) {
      _showErrorDialog("Gagal mengambil data operator: $e");
    }
  }

  Future<void> _fetchAlatTersedia() async {
    const String apiUrl = "http://192.168.1.101:8000/api/inventory-tersedia";
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $_token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _alatTersedia = List<Map<String, dynamic>>.from(data['data']);
        });
      } else {
        throw Exception("Failed to load alat: ${response.statusCode}");
      }
    } catch (e) {
      _showErrorDialog("Gagal mengambil data alat: $e");
    }
  }

  Future<void> _submitPengajuan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedOperatorId == null) {
      _showErrorDialog("Pilih operator terlebih dahulu!");
      return;
    }

    for (int i = 0; i < _detailPerawatan.length; i++) {
      if (_detailPerawatan[i].idAlat == null ||
          _detailPerawatan[i].tglMulai == null) {
        _showErrorDialog("Lengkapi semua detail perawatan!");
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      List<Map<String, dynamic>> details =
          _detailPerawatan.map((detail) {
            return {
              "id_alat": detail.idAlat,
              "tgl_mulai": detail.tglMulai?.toIso8601String(),
              "tgl_selesai": detail.tglSelesai?.toIso8601String(),
              "status": detail.status,
              "catatan": detail.catatan,
            };
          }).toList();

      final response = await http.post(
        Uri.parse("http://192.168.1.101:8000/api/perawatan"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
        body: jsonEncode({
          "id_operator": _selectedOperatorId,
          "details": details,
        }),
      );

      if (response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        final errorData = jsonDecode(response.body);
        _showErrorDialog(
          errorData['message'] ??
              "Terjadi kesalahan saat mengajukan perawatan!",
        );
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
          content: Text(
            "Apakah Anda yakin ingin mengajukan perawatan untuk ${_detailPerawatan.length} alat?",
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
          title: const Text("Error"),
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
    if (_isLoadingData) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text("Pengajuan Perawatan"),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.grey[100],
          shadowColor: Colors.transparent,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Memuat data..."),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Pengajuan Perawatan"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoadingData = true;
              });
              _loadToken();
            },
          ),
        ],
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
                    _buildOperatorDropdown(),
                    const SizedBox(height: 20),
                    _buildDetailPerawatanSection(),
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

  Widget _buildOperatorDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<int>(
            value:
                _operators.any((op) => op['id'] == _selectedOperatorId)
                    ? _selectedOperatorId
                    : null,
            decoration: _inputDecoration("Pilih Operator"),
            items:
                _operators.isEmpty
                    ? [
                      const DropdownMenuItem<int>(
                        value: null,
                        enabled: false,
                        child: Text("Tidak ada operator tersedia"),
                      ),
                    ]
                    : _operators.map((operator) {
                      return DropdownMenuItem<int>(
                        value: operator["id"],
                        child: Text(
                          operator["nama"]?.toString() ?? "Unknown Operator",
                        ),
                      );
                    }).toList(),
            onChanged:
                _operators.isEmpty
                    ? null
                    : (value) {
                      // Debug log
                      setState(() => _selectedOperatorId = value);
                    },
            validator: (value) => value == null ? "Pilih operator" : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPerawatanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Detail Perawatan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _detailPerawatan.length,
          itemBuilder: (context, index) {
            return _buildDetailPerawatanCard(index);
          },
        ),
      ],
    );
  }

  Widget _buildDetailPerawatanCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAlatDropdown(index),
            _buildDatePicker(
              "Tanggal Mulai",
              _detailPerawatan[index].tglMulai,
              (date) => setState(() => _detailPerawatan[index].tglMulai = date),
            ),
            _buildDatePicker(
              "Tanggal Selesai (Opsional)",
              _detailPerawatan[index].tglSelesai,
              (date) =>
                  setState(() => _detailPerawatan[index].tglSelesai = date),
              isOptional: true,
            ),
            _buildStatusDropdown(index),
            _buildCatatanField(index),
          ],
        ),
      ),
    );
  }

  Widget _buildAlatDropdown(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<int>(
            value:
                _alatTersedia.any(
                      (alat) => alat['id'] == _detailPerawatan[index].idAlat,
                    )
                    ? _detailPerawatan[index].idAlat
                    : null,
            decoration: _inputDecoration("Pilih Alat"),
            items:
                _alatTersedia.isEmpty
                    ? [
                      const DropdownMenuItem<int>(
                        value: null,
                        enabled: false,
                        child: Text("Tidak ada alat tersedia"),
                      ),
                    ]
                    : _alatTersedia.map((alat) {
                      return DropdownMenuItem<int>(
                        value: alat["id"],
                        child: Text(alat["nama"]?.toString() ?? "Unknown Alat"),
                      );
                    }).toList(),
            onChanged:
                _alatTersedia.isEmpty
                    ? null
                    : (value) {
                      // Debug log
                      setState(() => _detailPerawatan[index].idAlat = value);
                    },
            validator: (value) => value == null ? "Pilih alat" : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime? selectedDate,
    Function(DateTime) onDateChanged, {
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(
          selectedDate == null
              ? label
              : "$label: ${selectedDate.toLocal().toString().split(' ')[0]}",
          style: const TextStyle(fontSize: 16),
        ),
        tileColor: Colors.blue.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        trailing: const Icon(Icons.calendar_today, color: Colors.blue),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            onDateChanged(pickedDate);
          }
        },
      ),
    );
  }

  Widget _buildStatusDropdown(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _detailPerawatan[index].status,
        decoration: _inputDecoration("Status"),
        items: const [
          DropdownMenuItem(value: "pending", child: Text("Pending")),
          DropdownMenuItem(value: "proses", child: Text("Proses")),
          DropdownMenuItem(value: "selesai", child: Text("Selesai")),
        ],
        onChanged:
            (value) => setState(() => _detailPerawatan[index].status = value!),
        validator: (value) => value == null ? "Pilih status" : null,
      ),
    );
  }

  Widget _buildCatatanField(int index) {
    return TextFormField(
      maxLines: 3,
      decoration: _inputDecoration("Catatan (Opsional)"),
      onChanged: (value) => _detailPerawatan[index].catatan = value,
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

class DetailPerawatan {
  int? idAlat;
  DateTime? tglMulai;
  DateTime? tglSelesai;
  String status;
  String? catatan;

  DetailPerawatan({
    this.idAlat,
    this.tglMulai,
    this.tglSelesai,
    this.status = "pending",
    this.catatan,
  });
}
