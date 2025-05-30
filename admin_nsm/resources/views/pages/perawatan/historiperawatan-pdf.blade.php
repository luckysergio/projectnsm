<!DOCTYPE html>
<html>
<head>
    <title>Laporan Perawatan</title>
    <style>
        body { font-family: Arial, sans-serif; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: center; }
        th { background-color: #f2f2f2; }
        h2, h4 { text-align: center; margin-bottom: 0; }
    </style>
</head>
<body>
    <h2>Laporan Histori Perawatan</h2>
    <h4>{{ request('bulan') ? DateTime::createFromFormat('!m', request('bulan'))->format('F') : '-' }} {{ request('tahun') ?? '-' }}</h4>

    <table>
        <thead>
            <tr>
                
                <th>Nama Alat</th>
                <th>Operator</th>
                <th>Tanggal Mulai</th>
                <th>Tanggal Selesai</th>
                <th>Catatan</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($perawatan as $item)
            <tr>
                
                <td>{{ $item->inventori->nama_alat }}</td>
                <td>{{ $item->operator_name }}</td>
                <td>{{ \Carbon\Carbon::parse($item->tanggal_mulai)->format('d/m/Y') }}</td>
                <td>{{ \Carbon\Carbon::parse($item->tanggal_selesai)->format('d/m/Y') }}</td>
                <td>{{ $item->catatan }}</td>
            </tr>
            @endforeach
        </tbody>
    </table>

    <br><br>
    <h4>Total Perawatan: {{ $totalPerawatan }}</h4>
</body>
</html>
