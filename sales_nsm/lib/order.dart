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
  bool _isFetchingCustomers = true;
  String? _token;

  int? _selectedCustomerId;
  String _namaCustomerBaru = "";
  String _instansiCustomerBaru = "";
  bool _useExistingCustomer = true;

  final List<Map<String, dynamic>> _orderDetails = [];

  List<Map<String, dynamic>> _alatTersedia = [];
  List<Map<String, dynamic>> _customerList = [];

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return "-";
    }
  }

  String formatJam(String? time) {
    if (time == null || time.isEmpty) return "-";
    try {
      DateTime parsedTime = DateTime.parse("1970-01-01T$time");
      return "${DateFormat('HH.mm').format(parsedTime)} WIB";
    } catch (e) {
      return "-";
    }
  }

  @override
  void initState() {
    super.initState();
    _loadToken();
    _addNewOrderDetail();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    if (_token != null) {
      await Future.wait([_fetchAlatTersedia(), _fetchCustomers()]);
    } else {
      setState(() {
        _isFetchingAlat = false;
        _isFetchingCustomers = false;
      });
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
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          setState(() {
            _alatTersedia = List<Map<String, dynamic>>.from(
              responseData['data'],
            );
          });
        }
      }
    } finally {
      setState(() => _isFetchingAlat = false);
    }
  }

  Future<void> _fetchCustomers() async {
    const String apiUrl = "http://192.168.1.101:8000/api/customer";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $_token"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          setState(() {
            _customerList = List<Map<String, dynamic>>.from(
              responseData['data'],
            );
            if (_customerList.isNotEmpty) {
              _selectedCustomerId = _customerList.first['id'];
            }
          });
        }
      }
    } finally {
      setState(() => _isFetchingCustomers = false);
    }
  }

  void _addNewOrderDetail() {
    setState(() {
      _orderDetails.add({
        'id_alat': _alatTersedia.isNotEmpty ? _alatTersedia.first['id'] : null,
        'alamat': '',
        'tgl_mulai': null,
        'jam_mulai': null,
        'tgl_selesai': null,
        'jam_selesai': null,
        'total_sewa': 8,
        'catatan': '',
      });
    });
  }

  void _removeOrderDetail(int index) {
    if (_orderDetails.length > 1) {
      setState(() {
        _orderDetails.removeAt(index);
      });
    }
  }

  double _calculateTotalHarga() {
    double total = 0.0;
    for (var detail in _orderDetails) {
      if (detail['id_alat'] != null) {
        final alat = _alatTersedia.firstWhere(
          (alat) => alat['id'] == detail['id_alat'],
          orElse: () => {'harga': 0},
        );

        double harga =
            alat['harga'] is String
                ? double.tryParse(alat['harga']) ?? 0.0
                : (alat['harga'] ?? 0).toDouble();

        total += harga * detail['total_sewa'];
      }
    }
    return total;
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_useExistingCustomer && _selectedCustomerId == null) {
      _showErrorDialog("Pilih customer terlebih dahulu");
      return;
    }

    if (!_useExistingCustomer && _namaCustomerBaru.trim().isEmpty) {
      _showErrorDialog("Nama customer baru harus diisi");
      return;
    }

    for (int i = 0; i < _orderDetails.length; i++) {
      var detail = _orderDetails[i];
      if (detail['id_alat'] == null) {
        _showErrorDialog("Pilih alat untuk item ${i + 1}");
        return;
      }
      if (detail['alamat'].toString().trim().isEmpty) {
        _showErrorDialog("Alamat harus diisi untuk item ${i + 1}");
        return;
      }
      if (detail['tgl_mulai'] == null) {
        _showErrorDialog("Tanggal mulai harus diisi untuk item ${i + 1}");
        return;
      }
      if (detail['jam_mulai'] == null) {
        _showErrorDialog("Jam mulai harus diisi untuk item ${i + 1}");
        return;
      }
      if (detail['total_sewa'] < 8) {
        _showErrorDialog("Sewa minimal 8 Jam untuk item ${i + 1}");
        return;
      }
    }

    _formKey.currentState!.save();
    _showConfirmationDialog();
  }

  Future<void> _sendOrder() async {
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> requestBody = {"details": _orderDetails};

      if (_useExistingCustomer && _selectedCustomerId != null) {
        requestBody["customer_id"] = _selectedCustomerId;
      } else {
        requestBody["customer_baru"] = {
          "nama": _namaCustomerBaru.trim(),
          "instansi":
              _instansiCustomerBaru.trim().isEmpty
                  ? null
                  : _instansiCustomerBaru.trim(),
        };
      }

      final response = await http.post(
        Uri.parse("http://192.168.1.101:8000/api/order"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _showSuccessDialog(responseData["order"]["id"]);
      } else {
        String errorMessage = "Terjadi kesalahan.";

        if (responseData["errors"] != null) {
          Map<String, dynamic> errors = responseData["errors"];
          List<String> errorMessages = [];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.cast<String>());
            } else {
              errorMessages.add(value.toString());
            }
          });
          errorMessage = errorMessages.join('\n');
        } else if (responseData["message"] != null) {
          errorMessage = responseData["message"];
        }

        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      _showErrorDialog("Gagal terhubung ke server: $e");
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Apakah Anda yakin ingin membuat pesanan ini?"),
              const SizedBox(height: 10),
              Text(
                "Total: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_calculateTotalHarga())}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
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
                  "Order dengan ID SEWA-00$orderId telah berhasil dibuat.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
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
                    child: Center(
                      child: const Text(
                        "OK",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
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
            (_isFetchingAlat || _isFetchingCustomers)
                ? const Center(child: CircularProgressIndicator())
                : _alatTersedia.isEmpty
                ? const Center(child: Text("Tidak ada alat yang tersedia."))
                : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // Customer Section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Data Customer",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile<bool>(
                                      title: const Text("Customer Lama"),
                                      value: true,
                                      groupValue: _useExistingCustomer,
                                      onChanged: (value) {
                                        setState(() {
                                          _useExistingCustomer = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile<bool>(
                                      title: const Text("Customer Baru"),
                                      value: false,
                                      groupValue: _useExistingCustomer,
                                      onChanged: (value) {
                                        setState(() {
                                          _useExistingCustomer = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              if (_useExistingCustomer) ...[
                                _buildDropdownCustomer(),
                              ] else ...[
                                _buildTextField(
                                  "Nama Customer",
                                  (value) => _namaCustomerBaru = value,
                                ),
                                _buildTextField(
                                  "Instansi",
                                  (value) => _instansiCustomerBaru = value,
                                  required: false,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Detail Order",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: _addNewOrderDetail,
                                    icon: const Icon(Icons.add),
                                    label: const Text("Tambah Item"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              ..._orderDetails.asMap().entries.map((entry) {
                                int index = entry.key;
                                return _buildOrderDetailCard(index);
                              }),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Total Section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total Tagihan:",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: 'Rp ',
                                  decimalDigits: 0,
                                ).format(_calculateTotalHarga()),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Submit Button
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

  Widget _buildOrderDetailCard(int index) {
    var detail = _orderDetails[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Item ${index + 1}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (_orderDetails.length > 1)
                  IconButton(
                    onPressed: () => _removeOrderDetail(index),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<int>(
              value: detail['id_alat'],
              decoration: InputDecoration(
                labelText: "Jenis Alat",
                labelStyle: const TextStyle(color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items:
                  _alatTersedia
                      .map(
                        (alat) => DropdownMenuItem<int>(
                          value: alat["id"],
                          child: Text(alat["nama"] ?? ""),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _orderDetails[index]['id_alat'] = value;
                });
              },
              validator: (value) => value == null ? "Pilih alat" : null,
            ),

            const SizedBox(height: 10),

            TextFormField(
              initialValue: detail['alamat'],
              decoration: InputDecoration(
                labelText: "Alamat",
                labelStyle: const TextStyle(color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 2,
              validator:
                  (value) =>
                      value?.trim().isEmpty == true
                          ? "Alamat harus diisi"
                          : null,
              onChanged: (value) {
                _orderDetails[index]['alamat'] = value;
              },
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildDateField("Tanggal Mulai", detail['tgl_mulai'], (
                    pickedDate,
                  ) {
                    setState(() {
                      _orderDetails[index]['tgl_mulai'] =
                          pickedDate.toIso8601String().split('T')[0];
                    });
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTimeField("Jam Mulai", detail['jam_mulai'], (
                    pickedTime,
                  ) {
                    setState(() {
                      _orderDetails[index]['jam_mulai'] =
                          "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}:00";
                    });
                  }),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    "Tanggal Selesai (Opsional)",
                    detail['tgl_selesai'],
                    (pickedDate) {
                      setState(() {
                        _orderDetails[index]['tgl_selesai'] =
                            pickedDate.toIso8601String().split('T')[0];
                      });
                    },
                    required: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTimeField(
                    "Jam Selesai (Opsional)",
                    detail['jam_selesai'],
                    (pickedTime) {
                      setState(() {
                        _orderDetails[index]['jam_selesai'] =
                            "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}:00";
                      });
                    },
                    required: false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            _buildStepperTextField("Jumlah Sewa", detail['total_sewa'], (
              value,
            ) {
              setState(() {
                _orderDetails[index]['total_sewa'] = value;
              });
            }),

            const SizedBox(height: 10),

            TextFormField(
              initialValue: detail['catatan'],
              decoration: InputDecoration(
                labelText: "Catatan (Opsional)",
                labelStyle: const TextStyle(color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 2,
              onChanged: (value) {
                _orderDetails[index]['catatan'] = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    Function(String) onChanged, {
    bool isMultiline = false,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        maxLines: isMultiline ? 3 : 1,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey, width: 1.5),
          ),
        ),
        validator:
            required
                ? (value) => value!.trim().isEmpty ? "Harap isi $label" : null
                : null,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownCustomer() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<int>(
        value: _selectedCustomerId,
        decoration: InputDecoration(
          labelText: "Pilih Customer",
          labelStyle: const TextStyle(color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        items:
            _customerList
                .map(
                  (customer) => DropdownMenuItem<int>(
                    value: customer["id"],
                    child: Text(
                      "${customer["nama"]} - ${customer["instansi"] ?? 'Tanpa Instansi'}",
                    ),
                  ),
                )
                .toList(),
        onChanged: (value) {
          setState(() {
            _selectedCustomerId = value;
          });
        },
        validator:
            _useExistingCustomer
                ? (value) => value == null ? "Pilih customer" : null
                : null,
      ),
    );
  }

  Widget _buildDateField(
    String label,
    String? value,
    Function(DateTime) onChanged, {
    bool required = true,
  }) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      controller: TextEditingController(
        text: value == null ? '' : formatDate(value),
      ),
      validator:
          required
              ? (value) => value?.isEmpty == true ? "Pilih tanggal" : null
              : null,
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
    );
  }

  Widget _buildTimeField(
    String label,
    String? value,
    Function(TimeOfDay) onChanged, {
    bool required = true,
  }) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
        suffixIcon: const Icon(Icons.access_time),
      ),
      controller: TextEditingController(
        text: value == null ? '' : formatJam(value),
      ),
      validator:
          required
              ? (value) => value?.isEmpty == true ? "Pilih waktu" : null
              : null,
      onTap: () async {
        TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
    );
  }

  Widget _buildStepperTextField(
    String label,
    int value,
    Function(int) onValueChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: TextEditingController(text: value.toString()),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (newValue) {
              if (newValue.isNotEmpty && int.tryParse(newValue) != null) {
                int parsedValue = int.parse(newValue);
                if (parsedValue >= 8) {
                  onValueChanged(parsedValue);
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
                    onValueChanged(value - 1);
                  }
                  : null,
        ),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.green),
          onPressed: () {
            onValueChanged(value + 1);
          },
        ),
      ],
    );
  }
}
