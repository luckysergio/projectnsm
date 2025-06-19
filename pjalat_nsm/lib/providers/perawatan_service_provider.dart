import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pjalat_nsm/services/perawatan_service.dart';

final perawatanServiceProvider = Provider<PerawatanService>((ref) {
  final service = PerawatanService(ref);
  service.startPolling();
  return service;
});
