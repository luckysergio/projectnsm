import 'package:flutter/material.dart';
import 'company_profile_page.dart';
import 'invoice_form_page.dart';
import 'invoice_list_page.dart';
import 'offer_form_page.dart';
import 'offer_list_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Utama'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Baris 1: Nota
            Row(
              children: [
                _MenuCard(
                  icon: Icons.receipt_long,
                  title: 'Buat Nota',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InvoiceFormPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _MenuCard(
                  icon: Icons.list_alt,
                  title: 'Daftar Nota',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InvoiceListPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Baris 2: Penawaran
            Row(
              children: [
                _MenuCard(
                  icon: Icons.description_outlined,
                  title: 'Buat Penawaran',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OfferFormPage()),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _MenuCard(
                  icon: Icons.history,
                  title: 'Daftar Penawaran',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OfferListPage()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Baris 3: Profil Perusahaan (full width)
            _FullWidthMenuCard(
              icon: Icons.business,
              title: 'Profil Perusahaan',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CompanyProfilePage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Card biasa (setengah lebar)
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: Colors.blueAccent),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Card full-width (untuk profil perusahaan)
class _FullWidthMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _FullWidthMenuCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.blueAccent),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
