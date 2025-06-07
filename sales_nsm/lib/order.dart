import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFetchingAlat = true;
  String? _token;

  String _namaPemesan = "";
  String _alamatPemesan = "";
  int? _selectedAlatId;
  String? _tglPemakaian;
  String? _jamMulai;
  int _totalSewa = 8;
  String _selectedPembayaran = "belum dibayar";
  String catatan = "";
  double _totalHarga = 0.0;

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat(
        'dd-MM-yyyy',
      ).format(parsedDate); // format tanggal ke dd/MM/yyyy
    } catch (e) {
      return "-"; // jika format tanggal tidak valid
    }
  }

  String formatJam(String? time) {
    if (time == null || time.isEmpty) return "-";
    try {
      DateTime parsedTime = DateTime.parse(
        "1970-01-01T$time",
      ); // Parsing waktu (anggap tanggalnya tidak penting)
      return "${DateFormat('HH.mm').format(parsedTime)} WIB"; // Format jam dan menit, lalu tambahkan 'WIB'
    } catch (e) {
      return "-"; // Jika format waktu tidak valid
    }
  }

  List<Map<String, dynamic>> _alatTersedia = [];
  final List<String> metodePembayaran = ["Belum bayar", "DP", "Lunas"];

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    if (_token != null) {
      _fetchAlatTersedia();
    } else {
      setState(() => _isFetchingAlat = false);
    }
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
            _updateTotalHarga();
          }
        });
      }
    } catch (e) {
      print("Error fetching alat: $e");
    } finally {
      setState(() => _isFetchingAlat = false);
    }
  }

  void _updateTotalHarga() {
    if (_selectedAlatId != null) {
      final alat = _alatTersedia.firstWhere(
        (alat) => alat['id'] == _selectedAlatId,
      );

      double harga =
          alat['harga'] is String
              ? double.tryParse(alat['harga']) ?? 0.0
              : alat['harga'].toDouble();

      setState(() {
        _totalHarga = harga * _totalSewa;
      });
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAlatId == null) {
      _showErrorDialog("Tidak ada alat tersedia untuk dipesan.");
      return;
    }

    _formKey.currentState!.save();
    _showConfirmationDialog();
  }

  Future<void> _sendOrder() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.104:8000/api/orders"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
        body: jsonEncode({
          "nama_pemesan": _namaPemesan,
          "alamat_pemesan": _alamatPemesan,
          "inventori_id": _selectedAlatId,
          "tgl_pemakaian": _tglPemakaian,
          "jam_mulai": _jamMulai,
          "total_sewa": _totalSewa,
          "harga_sewa": _totalHarga,
          "status_pembayaran": _selectedPembayaran,
          "catatan": catatan,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201) {
        _showSuccessDialog(
          responseData["order"]["id"],
        ); // Tampilkan dialog sukses
      } else {
        _showErrorDialog(responseData["message"] ?? "Terjadi kesalahan.");
      }
    } catch (e) {
      _showErrorDialog("Gagal terhubung ke server.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi Order"),
          content: const Text("Apakah Anda yakin ingin membuat pesanan ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _sendOrder();
              },
              child: const Text("Ya, Buat Order"),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(int orderId) {
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
                  "Pesanan Berhasil!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Order dengan ID $orderId telah berhasil dibuat.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
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
          title: const Text("Gagal Membuat Order"),
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
        title: const Text("Buat Order Baru"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isFetchingAlat
                ? const Center(child: CircularProgressIndicator())
                : _alatTersedia.isEmpty
                ? const Center(child: Text("Tidak ada alat yang tersedia."))
                : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildTextField(
                        "Nama Pemesan",
                        (value) => _namaPemesan = value,
                      ),
                      _buildTextField(
                        "Alamat Pemesan",
                        (value) => _alamatPemesan = value,
                        isMultiline: true,
                      ),
                      _buildDropdownAlat(),
                      _buildStepperTextField("Jumlah Jam", _totalSewa, (value) {
                        setState(() {
                          _totalSewa = value;
                        });
                        _updateTotalHarga();
                      }),
                      _buildDateField("Tanggal Pemakaian", _tglPemakaian, (
                        pickedDate,
                      ) {
                        setState(() {
                          _tglPemakaian = pickedDate.toIso8601String();
                        });
                      }),
                      _buildTimeField("Jam Mulai", _jamMulai, (pickedTime) {
                        setState(() {
                          _jamMulai =
                              "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                        });
                      }),
                      _buildDropdownPembayaran(),
                      _buildTextField("Catatan", (value) => catatan = value),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: TextField(
                          controller: TextEditingController(
                            text: NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(_totalHarga),
                          ),
                          decoration: InputDecoration(
                            labelText: "Total Harga",
                            labelStyle: const TextStyle(color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                            onPressed: _submitOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              "Buat Order",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
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
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.grey, width: 1.5),
          ),
        ),
        validator: (value) => value!.isEmpty ? "Harap isi $label" : null,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownAlat() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<int>(
        value: _selectedAlatId,
        decoration: InputDecoration(
          labelText: "Jenis Alat",
          labelStyle: const TextStyle(color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        items:
            _alatTersedia
                .map(
                  (alat) => DropdownMenuItem<int>(
                    value: alat["id"],
                    child: Text(alat["nama_alat"]),
                  ),
                )
                .toList(),
        onChanged: (value) {
          setState(() {
            _selectedAlatId = value;
          });
          _updateTotalHarga();
        },
      ),
    );
  }

  Widget _buildDropdownPembayaran() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedPembayaran,
        decoration: InputDecoration(
          labelText: "Status Pembayaran",
          labelStyle: const TextStyle(color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        items:
            ["belum dibayar", "dp", "lunas"]
                .map(
                  (status) => DropdownMenuItem<String>(
                    value: status,
                    child: Text(status.toUpperCase()),
                  ),
                )
                .toList(),
        onChanged: (value) => setState(() => _selectedPembayaran = value!),
      ),
    );
  }

  Widget _buildDateField(
    String label,
    String? value,
    Function(DateTime) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            ),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          controller: TextEditingController(
            text: value == null ? '' : formatDate(value),
          ),
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTimeField(
    String label,
    String? value,
    Function(TimeOfDay) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            ),
            suffixIcon: Icon(Icons.access_time),
          ),
          controller: TextEditingController(
            text: value == null ? '' : formatJam(value),
          ),
          onTap: () async {
            TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStepperTextField(
    String label,
    int value,
    Function(int) onValueChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: TextEditingController(text: value.toString()),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (newValue) {
                if (newValue.isNotEmpty && int.tryParse(newValue) != null) {
                  int parsedValue = int.parse(newValue);
                  if (parsedValue >= 8) {
                    setState(() {
                      value = parsedValue;
                    });
                    onValueChanged(value);
                  }
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.red),
            onPressed:
                value > 8
                    ? () {
                      setState(() {
                        value--;
                      });
                      onValueChanged(value);
                    }
                    : null,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.green),
            onPressed: () {
              setState(() {
                value++;
              });
              onValueChanged(value);
            },
          ),
        ],
      ),
    );
  }
}
