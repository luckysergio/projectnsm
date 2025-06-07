<!DOCTYPE html>
<html>
<head>
    <title>Laporan Order</title>
    <style>
        body { font-family: Arial, sans-serif; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: center; }
        th { background-color: #f2f2f2; }
        h2, h4 { text-align: center; margin-bottom: 0; }
    </style>
</head>
<body>
    <h2>Laporan Histori Order</h2>
    <h4>{{ request('bulan') ? DateTime::createFromFormat('!m', request('bulan'))->format('F') : '-' }} {{ request('tahun') ?? '-' }}</h4>

    <table>
        <thead>
            <tr>
                <th>Sales</th>
                <th>Pemesan</th>
                <th>Alat</th>
                <th>Total Harga</th>
                <th>Tanggal Pengiriman</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($orders as $order)
            <tr>
                <td>{{ $order->sales_name }}</td>
                <td>{{ $order->nama_pemesan }}</td>
                <td>{{ $order->inventori_name }}</td>
                <td>Rp {{ number_format($order->total_harga, 0, ',', '.') }}</td>
                <td>{{ \Carbon\Carbon::parse($order->tgl_pemakaian)->format('d/m/Y') }}</td>
            </tr>
            @endforeach
        </tbody>
    </table>

    <br><br>
    <h4>Total Order: {{ $totalOrder }}</h4>
    <h4>Total Pendapatan: Rp {{ number_format($totalHarga, 0, ',', '.') }}</h4>
</body>
</html>
