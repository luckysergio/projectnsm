String terbilang(int number) {
  if (number == 0) return 'Nol Rupiah';

  final units = [
    '',
    'Satu',
    'Dua',
    'Tiga',
    'Empat',
    'Lima',
    'Enam',
    'Tujuh',
    'Delapan',
    'Sembilan',
    'Sepuluh',
    'Sebelas',
  ];

  String convert(int n) {
    if (n < 12) {
      return units[n];
    } else if (n < 20) {
      return '${units[n - 10]} Belas';
    } else if (n < 100) {
      return '${units[n ~/ 10]} Puluh ${convert(n % 10)}';
    } else if (n < 200) {
      return 'Seratus ${convert(n - 100)}';
    } else if (n < 1000) {
      return '${units[n ~/ 100]} Ratus ${convert(n % 100)}';
    } else if (n < 2000) {
      return 'Seribu ${convert(n - 1000)}';
    } else if (n < 1000000) {
      return '${convert(n ~/ 1000)} Ribu ${convert(n % 1000)}';
    } else if (n < 1000000000) {
      return '${convert(n ~/ 1000000)} Juta ${convert(n % 1000000)}';
    } else {
      return '${convert(n ~/ 1000000000)} Miliar ${convert(n % 1000000000)}';
    }
  }

  return '${convert(number).trim()} Rupiah';
}
