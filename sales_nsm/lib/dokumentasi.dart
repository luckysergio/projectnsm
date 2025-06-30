import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class DokumentasiOrderPage extends StatefulWidget {
  const DokumentasiOrderPage({super.key});

  @override
  State<DokumentasiOrderPage> createState() => _DokumentasiOrderPageState();
}

class _DokumentasiOrderPageState extends State<DokumentasiOrderPage> {
  String? _selectedOrder;
  final List<File> _imageFiles = [];
  String _catatan = "";
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _orderList = [];
  bool _isLoadingOrders = true;
  bool _isUploading = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchOrders();
  }

  Future<void> _loadTokenAndFetchOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    if (_token != null) {
      await _fetchPendingOrders();
    } else {
      setState(() => _isLoadingOrders = false);
      _showDialog("Token tidak ditemukan. Silakan login ulang.", Colors.red);
    }
  }

  Future<void> _fetchPendingOrders() async {
    const String apiUrl = "http://192.168.1.101:8000/api/orders/active";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $_token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["orders"] != null) {
          setState(() {
            _orderList = List<Map<String, dynamic>>.from(data["orders"]);
            if (_orderList.isNotEmpty) {
              _selectedOrder = _orderList.first["id"].toString();
            }
          });
        } else {
          _showDialog("Data order kosong.", Colors.orange);
        }
      } else {
        _showDialog("Gagal memuat order: ${response.statusCode}", Colors.red);
      }
    } catch (e) {
      _showDialog("Terjadi kesalahan saat mengambil data: $e", Colors.red);
    } finally {
      setState(() => _isLoadingOrders = false);
    }
  }

  Future<void> _pickMultipleImages() async {
    if (_imageFiles.length >= 10) {
      _showDialog("Maksimal hanya bisa mengunggah 10 foto!", Colors.red);
      return;
    }

    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        int remaining = 10 - _imageFiles.length;
        _imageFiles.addAll(
          pickedFiles.take(remaining).map((xfile) => File(xfile.path)),
        );
        if (pickedFiles.length > remaining) {
          _showDialog("Maksimal hanya bisa unggah 10 foto!", Colors.red);
        }
      });
    }
  }

  Future<void> _postDokumentasi() async {
    if (_selectedOrder == null) {
      _showDialog("Silakan pilih ID Order!", Colors.red);
      return;
    }
    if (_catatan.trim().isEmpty) {
      _showDialog("Catatan tidak boleh kosong!", Colors.red);
      return;
    }
    if (_imageFiles.isEmpty) {
      _showDialog("Pilih minimal satu foto!", Colors.red);
      return;
    }

    setState(() => _isUploading = true);
    const String apiUrl = "http://192.168.1.101:8000/api/dokumentasi";

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $_token';
      request.headers['Accept'] = 'application/json';
      request.fields['order_id'] = _selectedOrder!;
      request.fields['note'] = _catatan;

      for (int i = 0; i < _imageFiles.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo[$i]',
            _imageFiles[i].path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        _showSuccessDialog();
        setState(() {
          _imageFiles.clear();
          _catatan = "";
        });
      } else {
        final error = jsonDecode(responseBody);
        _showDialog(
          "Gagal upload: ${error['message'] ?? 'Error tidak diketahui'}",
          Colors.red,
        );
      }
    } catch (e) {
      _showDialog("Kesalahan saat upload: $e", Colors.red);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showDialog(String message, Color color) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Pemberitahuan", style: TextStyle(color: color)),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Berhasil"),
            content: const Text("Dokumentasi berhasil diunggah."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Center(child: const Text("OK")),
              ),
            ],
          ),
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: onChanged,
      maxLines: null,
      keyboardType: TextInputType.multiline,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Buat Dokumentasi Order"),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _isLoadingOrders
                ? const Center(child: CircularProgressIndicator())
                : _buildDropdownOrder(),
            const SizedBox(height: 16),
            _buildImageUploadSection(),
            const SizedBox(height: 16),
            _buildTextField("Catatan", (val) => _catatan = val),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _postDokumentasi,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child:
                  _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Simpan Dokumentasi"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownOrder() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: _selectedOrder,
      decoration: InputDecoration(
        labelText: "Pilih Order",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      items:
          _orderList.map((order) {
            final displayName =
                order["customer"]?["nama"]?.toString() ??
                "Order ID ${order["id"]}";
            return DropdownMenuItem(
              value: order["id"].toString(),
              child: Text(displayName, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
      onChanged: (value) => setState(() => _selectedOrder = value),
    );
  }

  Widget _buildImageUploadSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Upload Foto (Maksimal 10)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  _imageFiles.asMap().entries.map((entry) {
                    int index = entry.key;
                    File file = entry.value;
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed:
                              () => setState(() => _imageFiles.removeAt(index)),
                        ),
                      ],
                    );
                  }).toList(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickMultipleImages,
              child: const Text("Pilih Foto"),
            ),
          ],
        ),
      ),
    );
  }
}
