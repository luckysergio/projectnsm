import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pjalat_nsm/login.dart';
import 'package:pjalat_nsm/providers/order_count_provider.dart';
import 'package:pjalat_nsm/providers/order_service_provider.dart';
import 'package:pjalat_nsm/providers/perawatan_count_provider.dart';
import 'package:pjalat_nsm/providers/perawatan_service_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart' as badges;
import 'jadwalpengiriman.dart';
import 'jadwalperawatan.dart';
import 'pengajuan.dart';
import 'historiperawatan.dart';
import 'historiorder.dart';
import 'inventory.dart';
import 'profile.dart';
import 'search_page.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const HistoriOrderPage(),
    const HistoriPerawatanPage(),
    const ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[100],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        showSelectedLabels: true,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Histori"),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_history),
            label: "Perawatan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  String _namaPjalat = "Nama Penanggung jawab alat";
  String _nikPjalat = "Nomer Induk Karyawan";
  String? _jabatan;

  @override
  void initState() {
    super.initState();
    checkTokenValidity(context);
    _loadUserData();
    _loadJabatan();
    ref.read(orderServiceProvider);
    ref.read(perawatanServiceProvider);
  }

  Future<void> checkTokenValidity(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.105:8000/api/auth/check'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401) {
        await prefs.clear();
        if (!context.mounted) return;

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (_) => AlertDialog(
                title: const Text('Sesi Habis'),
                content: const Text(
                  'Sesi login Anda telah habis. Silakan login kembali.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      debugPrint('Token check error: $e');
    }
  }

  Future<void> _loadJabatan() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _jabatan = prefs.getString('jabatan')?.toLowerCase();
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _nikPjalat = prefs.getInt('nik')?.toString() ?? 'NIK tidak ditemukan';
      _namaPjalat = prefs.getString('name') ?? 'Nama tidak ditemukan';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await ref.read(orderServiceProvider).fetchOrderCount();
          await ref.read(perawatanServiceProvider).fetchPerawatanCount();
        },
        backgroundColor: Colors.grey[100],
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildSectionHeader("Jenis-Jenis Pompa"),
            _buildFeaturedList(),
            const SizedBox(height: 16),
            _buildCategoryButtons(),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _namaPjalat,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(_nikPjalat, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ],
        ),
        // IconButton(
        //   icon: const Icon(Icons.notifications_outlined, size: 28),
        //   onPressed: () {},
        // ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchPage()),
        );
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withAlpha(50),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 10),
            Text(
              "Cari order dan perawatan ...",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InventoryPage()),
            );
          },
          child: const Text(
            "Lihat Semua",
            style: TextStyle(color: Colors.blue, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedList() {
    final List<Map<String, String>> featuredItems = [
      {
        "title": "Pompa Mini",
        "image": "assets/images/mini.png",
        "description":
            "Ukuran kendaraan lebih kecil Truckcold cocok untuk proyek dijalan yang terdapat gapura, untuk panjang belalai 12 - 15 Meter",
      },
      {
        "title": "Pompa Standart",
        "image": "assets/images/standart.png",
        "description":
            "Ukuran kendaraan Truck tronton, untuk panjang belalai 18 Meter Cocok untuk bangunan lantai 3 ke bawah",
      },
      {
        "title": "Pompa Long Boom",
        "image": "assets/images/longboom.png",
        "description":
            "Ukuran kendaraan truck tronton, untuk panjang belalai 28 Meter Cocok untuk bangunan lantai 3 ke atas",
      },
      {
        "title": "Pompa Super Long",
        "image": "assets/images/super-longboom.png",
        "description":
            "Ukuran kendaraan truck tronton, untuk panjang belalai 33 - 35 Meter",
      },
      {
        "title": "Pompa Kodok",
        "image": "assets/images/kodok.png",
        "description":
            "Ukuran mesin seperti genset cocok digunakan untuk pengerjaan coran yang fleksibel",
      },
    ];

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: featuredItems.length,
        itemBuilder: (context, index) {
          final item = featuredItems[index];

          return GestureDetector(
            onTap: () {
              _showDetailDialog(
                item["title"]!,
                item["description"]!,
                item["image"]!,
              );
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withAlpha(38),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.asset(
                      item["image"]!,
                      width: 160,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      item["title"]!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Tap untuk detail",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDetailDialog(String title, String description, String image) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    image,
                    width: 260,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Tutup",
                      style: TextStyle(color: Colors.white),
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

  Widget _buildCategoryButtons() {
    if (_jabatan == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (_jabatan == 'penanggung jawab alat' ||
            _jabatan == 'operator alat') ...[
          Consumer(
            builder: (context, ref, child) {
              final jumlahOrderAktif = ref.watch(orderCountProvider);
              return _buildCategoryButton(
                "Jadwal Pengiriman Alat",
                Icons.local_shipping,
                Colors.blue,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JadwalPengirimanPage(),
                    ),
                  );
                },
                badgeCount: jumlahOrderAktif,
              );
            },
          ),
        ],

        if (_jabatan == 'penanggung jawab alat' ||
            _jabatan == 'operator maintenance') ...[
          Consumer(
            builder: (context, ref, child) {
              final jumlahPerawatan = ref.watch(perawatanCountProvider);
              return _buildCategoryButton(
                "Jadwal Perawatan Alat",
                Icons.list_alt,
                Colors.green,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JadwalPerrawatanPage(),
                    ),
                  );
                },
                badgeCount: jumlahPerawatan,
              );
            },
          ),
        ],

        if (_jabatan == 'penanggung jawab alat') ...[
          _buildCategoryButton(
            "Buat jadwal Perawatan Alat",
            Icons.build,
            Colors.orange,
            () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PengajuanPerawatanPage(),
                ),
              );

              if (result == true) {
                await ref.read(perawatanServiceProvider).fetchPerawatanCount();
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    int badgeCount = 0,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withAlpha(50),
              blurRadius: 5,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            badges.Badge(
              showBadge: badgeCount > 0,
              badgeContent: Text(
                badgeCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/images/logo-CV.png", height: 80),
          const SizedBox(height: 6),
          const Text(
            "Kami adalah penyedia solusi pompa terbaik dengan layanan berkualitas dan terpercaya di seluruh Indonesia.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
