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
    }
  }

  Future<void> _fetchPendingOrders() async {
    const String apiUrl = "http://192.168.1.104:8000/api/orders/pending";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $_token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _orderList = List<Map<String, dynamic>>.from(data["orders"]);
          if (_orderList.isNotEmpty) {
            _selectedOrder = _orderList.first["id"].toString();
          }
        });
      }
    } catch (e) {
      print("Error fetching orders: $e");
    } finally {
      setState(() => _isLoadingOrders = false);
    }
  }

  Future<void> _pickMultipleImages() async {
    if (_imageFiles.length >= 5) {
      _showDialog("Maksimal hanya bisa mengunggah 5 foto!", Colors.red);
      return;
    }

    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        int remainingSlots = 5 - _imageFiles.length;
        List<XFile> filesToAdd = pickedFiles.take(remainingSlots).toList();

        _imageFiles.addAll(filesToAdd.map((file) => File(file.path)));
        if (pickedFiles.length > remainingSlots) {
          _showDialog("Maksimal hanya bisa mengunggah 5 foto!", Colors.red);
        }
      });
    }
  }

  Future<void> _postDokumentasi() async {
    if (_selectedOrder == null) {
      _showDialog("Silakan pilih ID Order!", Colors.red);
      return;
    }

    if (_selectedOrder == null) {
      _showDialog("Silakan pilih ID Order!", Colors.red);
      return;
    }

    if (_catatan.isEmpty) {
      _showDialog("Catatan tidak boleh kosong!", Colors.red);
      return;
    }

    if (_imageFiles.isEmpty) {
      _showDialog("Pilih setidaknya satu foto untuk diunggah!", Colors.red);
      return;
    }

    setState(() => _isUploading = true);
    const String apiUrl = "http://192.168.1.104:8000/api/order-documents";

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
      } else {
        _showDialog("Gagal upload: $responseBody", Colors.red);
      }
    } catch (e) {
      _showDialog("Error: $e", Colors.red);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showDialog(String message, Color color) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Pemberitahuan", style: TextStyle(color: color)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Dokumentasi Berhasil!"),
          content: const Text("Dokumentasi telah berhasil disimpan."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Buat Dokumentasi order"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
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
            _buildTextField("Catatan", (value) => _catatan = value),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _postDokumentasi,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: _selectedOrder,
        decoration: InputDecoration(
          labelText: "Pilih Order",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
        ),
        items:
            _orderList.map((order) {
              return DropdownMenuItem(
                value: order["id"].toString(),
                child: Text(
                  "${order["nama_pemesan"]}",
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
        onChanged: (value) => setState(() => _selectedOrder = value),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upload Foto (Maksimal 5)",
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
