import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PembayaranPage extends StatefulWidget {
  final dynamic order;

  const PembayaranPage({super.key, required this.order});

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  String? _token;

  final String baseUrl = 'http://192.168.1.101:8000/api';

  String formatCurrency(dynamic number) {
    try {
      final parsed =
          number is String
              ? int.tryParse(number.replaceAll(RegExp(r'[^\d]'), '')) ?? 0
              : (number is num ? number.toInt() : 0);

      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(parsed);
    } catch (_) {
      return 'Rp 0';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1920,
                    maxHeight: 1080,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Ambil Foto'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1920,
                    maxHeight: 1080,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmationDialog() {
    if (_selectedImage == null) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Center(child: const Text('Peringatan')),
              content: const Text(
                'Silakan upload bukti pembayaran terlebih dahulu.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Center(child: const Text('OK')),
                ),
              ],
            ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Pembayaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID Pembayaran: ${widget.order['id']}'),
              Text('Jumlah Dibayar: ${formatCurrency(_jumlahController.text)}'),
              const SizedBox(height: 10),
              if (_selectedImage != null)
                const Text('✓ Bukti pembayaran telah dipilih')
              else
                const Text('⚠ Bukti pembayaran tidak dipilih'),
              const SizedBox(height: 15),
              const Text(
                'Apakah Anda yakin ingin melanjutkan pembayaran?',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitPembayaran();
              },
              child: const Text('Ya, Lanjutkan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitPembayaran() async {
    if (!_formKey.currentState!.validate()) return;

    if (_token == null) {
      _showErrorDialog({
        'message': 'Token tidak ditemukan. Silakan login kembali.',
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/detail'));

      request.headers.addAll({
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      });

      request.fields['id_pembayaran'] = widget.order['id'].toString();
      final rawJumlah = _jumlahController.text.replaceAll(RegExp(r'[^\d]'), '');
      request.fields['jml_dibayar'] = rawJumlah;

      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('bukti', _selectedImage!.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        _showSuccessDialog(responseData['message']);
      } else {
        try {
          var errorData = json.decode(response.body);
          _showErrorDialog(errorData);
        } catch (e) {
          _showErrorDialog({
            'message':
                'Server error: ${response.statusCode} - ${response.body}',
          });
        }
      }
    } catch (e) {
      _showErrorDialog({'message': 'Terjadi kesalahan jaringan: $e'});
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
          title: const Text('Pembayaran Berhasil'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Center(child: const Text('OK')),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(Map<String, dynamic> errorData) {
    String errorMessage = 'Terjadi kesalahan';

    if (errorData.containsKey('errors')) {
      Map<String, dynamic> errors = errorData['errors'];
      List<String> errorList = [];
      errors.forEach((key, value) {
        if (value is List) {
          errorList.addAll(value.cast<String>());
        } else {
          errorList.add(value.toString());
        }
      });
      errorMessage = errorList.join('\n');
    } else if (errorData.containsKey('message')) {
      errorMessage = errorData['message'];
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.error, color: Colors.red, size: 64),
          title: const Text('Pembayaran Gagal'),
          content: Text(errorMessage),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Center(child: const Text('OK')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pembayaran'),
        centerTitle: true,
        elevation: 0,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Pembayaran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ID Pembayaran: ${widget.order['id']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (widget.order['total'] != null)
                        Text(
                          'Total Tagihan: Rp ${widget.order['total']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      if (widget.order['status'] != null)
                        Text(
                          'Status: ${widget.order['status']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Dibayar',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                  helperText: 'Masukkan jumlah yang akan dibayar',
                ),
                onChanged: (value) {
                  String digits = value.replaceAll(RegExp(r'[^\d]'), '');
                  if (digits.isEmpty) return;
                  final number = int.parse(digits);
                  final formatted = NumberFormat.decimalPattern(
                    'id_ID',
                  ).format(number);
                  _jumlahController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah pembayaran harus diisi';
                  }
                  final digits = value.replaceAll(RegExp(r'[^\d]'), '');
                  if (digits.isEmpty || int.tryParse(digits) == null) {
                    return 'Jumlah harus berupa angka';
                  }
                  if (int.parse(digits) <= 0) {
                    return 'Jumlah harus lebih dari 0';
                  }
                  return null;
                },
              ),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bukti Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_selectedImage != null) ...[
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.edit),
                                label: const Text('Ganti Gambar'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                                icon: const Icon(Icons.delete),
                                label: const Text('Hapus'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            onTap: _pickImage,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tap untuk upload bukti pembayaran',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _showConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child:
                      _isLoading
                          ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Memproses...'),
                            ],
                          )
                          : const Text(
                            'Submit Pembayaran',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
