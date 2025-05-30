import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider jumlah jadwal pengiriman
final pengirimanCountProvider = StateProvider<int>((ref) => 0);

// Provider jumlah jadwal perawatan
final perawatanCountProvider = StateProvider<int>((ref) => 0);
