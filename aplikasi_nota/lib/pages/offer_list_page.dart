import 'package:flutter/material.dart';
import '../models/offer.dart';
import '../repositories/offer_repository.dart';
import 'offer_pdf_page.dart'; // Pastikan Anda buat ini

class OfferListPage extends StatefulWidget {
  const OfferListPage({super.key});

  @override
  State<OfferListPage> createState() => _OfferListPageState();
}

class _OfferListPageState extends State<OfferListPage> {
  List<Offer> offers = [];
  List<Offer> filteredOffers = [];
  bool loading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadOffers();
    _searchController.addListener(_filterOffers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterOffers);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadOffers() async {
    setState(() => loading = true);
    final repo = OfferRepository();
    offers = await repo.getOffers();
    filteredOffers = List.from(offers);
    setState(() => loading = false);
  }

  void _filterOffers() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        filteredOffers = List.from(offers);
      });
      return;
    }

    final filtered = offers.where((offer) {
      final matchesName = offer.customerName.toLowerCase().contains(query);
      final matchesNumber = offer.offerNumber.toLowerCase().contains(query);
      return matchesName || matchesNumber;
    }).toList();

    setState(() {
      filteredOffers = filtered;
    });
  }

  String formatTanggal(String isoDate) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    try {
      final date = DateTime.parse(isoDate);
      final day = date.day.toString().padLeft(2, '0');
      final month = months[date.month - 1];
      final year = date.year;
      return '$day $month $year';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Penawaran'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama atau no penawaran...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Daftar Penawaran
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : filteredOffers.isEmpty
                    ? const Center(child: Text('Tidak ada penawaran ditemukan'))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: filteredOffers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final offer = filteredOffers[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                foregroundColor: Colors.green,
                                child: Text('${index + 1}'),
                              ),
                              title: Text(
                                offer.customerName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(offer.subject),
                                  Text(offer.project),
                                  Text(offer.offerNumber),
                                  Text(formatTanggal(offer.offerDate)),
                                ],
                              ),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.print, color: Colors.blue),
                                onPressed: () async {
                                  // Cek eksplisit untuk null
                                  if (offer.id == null || offer.id == 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('ID penawaran tidak valid')),
                                    );
                                    return;
                                  }

                                  try {
                                    final repo = OfferRepository();
                                    final items =
                                        await repo.getItemsByOffer(offer.id!);
                                    if (!context.mounted) return;

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OfferPdfPage(
                                            offer: offer, items: items),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
