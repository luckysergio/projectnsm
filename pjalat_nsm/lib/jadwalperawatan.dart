import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JadwalPerrawatanPage extends StatefulWidget {
  const JadwalPerrawatanPage({super.key});

  @override
  JadwalPerrawatanPageState createState() => JadwalPerrawatanPageState();
}

class JadwalPerrawatanPageState extends State<JadwalPerrawatanPage> {
  late Future<List<Map<String, dynamic>>> _perawatanFuture;
  String? _token;

  @override
  void initState() {
    super.initState();
    _perawatanFuture = _fetchPerawatans();
  }

  Future<List<Map<String, dynamic>>> _fetchPerawatans() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final jabatan = prefs.getString('jabatan')?.toLowerCase();
    final idKaryawan = prefs.getInt('id_karyawan');

    if (_token == null) {
      if (!mounted) return [];
      _showDialog("Error", "Token tidak ditemukan, silakan login kembali.");
      return [];
    }

    Uri url;

    if (jabatan == 'operator maintenance' && idKaryawan != null) {
      url = Uri.parse(
        "http://192.168.1.105:8000/api/perawatan/active/operator/$idKaryawan",
      );
    } else {
      url = Uri.parse("http://192.168.1.105:8000/api/perawatan/active/public");
    }

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $_token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data["perawatans"]);
    } else {
      if (!mounted) return [];
      _showDialog("Error", "Gagal mengambil data perawatan.");
      return [];
    }
  }

  void _showDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
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
        title: const Text("Jadwal Perawatan Alat"),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _perawatanFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Tidak ada jadwal perawatan."));
            }

            final perawatans = snapshot.data!;
            return ListView.builder(
              itemCount: perawatans.length,
              itemBuilder: (context, index) {
                final perawatan = perawatans[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(
                      Icons.build_circle,
                      size: 40,
                      color: Colors.green,
                    ),
                    title: Text(
                      "Perawatan-00${perawatan['id']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Operator: ${perawatan["operator"]?["nama"] ?? "-"}",
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DetailPerawatanPage(
                                perawatan: perawatan,
                                token: _token!,
                                onReload: () {
                                  setState(() {
                                    _perawatanFuture = _fetchPerawatans();
                                  });
                                },
                              ),
                        ),
                      );

                      if (result == true) {
                        setState(() {
                          _perawatanFuture = _fetchPerawatans();
                        });
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class DetailPerawatanPage extends StatefulWidget {
  final Map<String, dynamic> perawatan;
  final String token;
  final VoidCallback onReload;

  const DetailPerawatanPage({
    super.key,
    required this.perawatan,
    required this.token,
    required this.onReload,
  });

  @override
  State<DetailPerawatanPage> createState() => _DetailPerrawatanPageState();
}

class _DetailPerrawatanPageState extends State<DetailPerawatanPage> {
  String? _jabatan;

  @override
  void initState() {
    super.initState();
    _loadJabatan();
  }

  Future<void> _loadJabatan() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _jabatan = prefs.getString('jabatan')?.toLowerCase();
    });
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
    } catch (_) {
      return "-";
    }
  }

  Future<void> _showDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ),
            ],
          ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchOperatorMaintenance() async {
    final response = await http.get(
      Uri.parse("http://192.168.1.105:8000/api/karyawan/operator-maintenance"),
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data["operators"] ?? []);
    } else {
      throw Exception("Gagal mengambil data operator");
    }
  }

  void _showProsesDialog(BuildContext context) async {
    final TextEditingController catatanController = TextEditingController();
    String selectedStatus =
        widget.perawatan['detail_perawatans']?[0]['status'] ?? "selesai";
    DateTime selectedDate = DateTime.now();
    int? selectedOperatorId = widget.perawatan['operator']?['id'];

    List<Map<String, dynamic>> operators = [];
    try {
      operators = await _fetchOperatorMaintenance();
      if (selectedOperatorId != null &&
          !operators.any((op) => op['id'] == selectedOperatorId)) {
        operators.add({
          'id': selectedOperatorId,
          'nama': widget.perawatan['operator']?['nama'] ?? 'Unknown',
        });
      }
    } catch (e) {
      if (context.mounted) {
        _showDialog(context, "Error", "Gagal memuat operator: $e");
      }
      return;
    }

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text("Proses Perawatan"),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        DropdownButtonFormField<int>(
                          value: selectedOperatorId,
                          decoration: const InputDecoration(
                            labelText: 'Pilih Operator',
                            border: OutlineInputBorder(),
                          ),
                          isExpanded: true,
                          items:
                              operators.map((operator) {
                                return DropdownMenuItem<int>(
                                  value: operator['id'],
                                  child: Text(operator['nama'] ?? 'Unknown'),
                                );
                              }).toList(),
                          onChanged:
                              (val) => setState(() => selectedOperatorId = val),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: "pending",
                              child: Text("Pending"),
                            ),
                            DropdownMenuItem(
                              value: "proses",
                              child: Text("Proses"),
                            ),
                            DropdownMenuItem(
                              value: "selesai",
                              child: Text("Selesai"),
                            ),
                          ],
                          onChanged:
                              (val) => setState(() => selectedStatus = val!),
                        ),
                        const SizedBox(height: 16),
                        if (selectedStatus == "selesai")
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() => selectedDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Tanggal Selesai: ${DateFormat('dd-MM-yyyy').format(selectedDate)}",
                                  ),
                                  const Icon(Icons.calendar_today),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: catatanController,
                          decoration: const InputDecoration(
                            labelText: 'Catatan',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text("Batal"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      child: const Text("Simpan"),
                      onPressed: () async {
                        if (selectedOperatorId == null) {
                          _showDialog(
                            context,
                            "Peringatan",
                            "Pilih operator terlebih dahulu",
                          );
                          return;
                        }

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder:
                              (_) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                        );

                        try {
                          final detailPerawatans =
                              widget.perawatan['detail_perawatans'] ?? [];
                          final details =
                              detailPerawatans.map<Map<String, dynamic>>((
                                detail,
                              ) {
                                return {
                                  "id_alat": detail['id_alat'],
                                  "tgl_mulai": detail['tgl_mulai'],
                                  "tgl_selesai":
                                      selectedStatus == "selesai"
                                          ? selectedDate
                                              .toIso8601String()
                                              .split('T')[0]
                                          : null,
                                  "status": selectedStatus,
                                  "catatan":
                                      catatanController.text.isEmpty
                                          ? null
                                          : catatanController.text,
                                };
                              }).toList();

                          final requestBody = {
                            "id_operator": selectedOperatorId,
                            "details": details,
                          };

                          final response = await http.put(
                            Uri.parse(
                              "http://192.168.1.105:8000/api/perawatan/${widget.perawatan['id']}",
                            ),
                            headers: {
                              "Authorization": "Bearer ${widget.token}",
                              "Content-Type": "application/json",
                              "Accept": "application/json",
                            },
                            body: jsonEncode(requestBody),
                          );

                          if (!context.mounted) return;
                          Navigator.of(context, rootNavigator: true).pop();

                          if (response.statusCode == 200) {
                            Navigator.pop(context);

                            await showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text("Sukses"),
                                    content: const Text(
                                      "Detail perawatan berhasil diproses.",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.pop(context, true);
                                        },
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  ),
                            );
                          } else {
                            final errorData = jsonDecode(response.body);
                            _showDialog(
                              context,
                              "Error",
                              errorData['message'] ?? "Gagal memproses",
                            );
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pop(); // Tutup loading dialog
                          _showDialog(
                            context,
                            "Error",
                            "Terjadi kesalahan: $e",
                          );
                        }
                      },
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List detailPerawatans = widget.perawatan["detail_perawatans"] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Perawatan-00${widget.perawatan['id']}"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildRow(
                    "Operator",
                    widget.perawatan["operator"]?["nama"] ?? "-",
                  ),
                  const Divider(),
                  for (var d in detailPerawatans) ...[
                    Center(
                      child: Text(
                        "Pompa ${d["alat"]?["nama"] ?? "-"}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildRow("Tanggal Mulai", formatDate(d["tgl_mulai"])),
                    if (d["status"] == "selesai")
                      _buildRow(
                        "Tanggal Selesai",
                        formatDate(d["tgl_selesai"]),
                      ),
                    _buildRow("Status", d["status"] ?? "-"),
                    _buildRow("Catatan", d["catatan"] ?? "-"),
                    const Divider(),
                  ],
                  const SizedBox(height: 20),
                  _jabatan == "penanggung jawab alat"
                      ? ElevatedButton.icon(
                        icon: const Icon(Icons.build),
                        label: const Text("Proses Perawatan"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _showProsesDialog(context),
                      )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}
