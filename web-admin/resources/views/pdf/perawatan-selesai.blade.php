<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Laporan Perawatan Selesai</title>
    <style>
        body { font-family: sans-serif; font-size: 12px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #000; padding: 6px; text-align: left; }
        th { background-color: #eee; }
        h2 { text-align: center; margin-bottom: 0; }
        .small { font-size: 10px; }
    </style>
</head>
<body>

    <h2>Laporan Perawatan Selesai</h2>

    @php
        $namaBulan = [
            1 => 'Januari', 2 => 'Februari', 3 => 'Maret', 4 => 'April',
            5 => 'Mei', 6 => 'Juni', 7 => 'Juli', 8 => 'Agustus',
            9 => 'September', 10 => 'Oktober', 11 => 'November', 12 => 'Desember',
        ];
    @endphp

    @if(request('bulan') && request('tahun'))
        <p><strong>Periode:</strong> {{ $namaBulan[(int) request('bulan')] ?? '-' }} {{ request('tahun') }}</p>
    @endif

    <table>
        <thead>
            <tr>
                <th>No</th>
                <th>Nama Operator</th>
                <th>Nama Alat</th>
                <th>Tanggal Selesai</th>
                <th>Status</th>
                <th>Catatan</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($perawatans as $index => $perawatan)
                @foreach ($perawatan->detailPerawatans as $detail)
                    <tr>
                        <td>{{ $index + 1 }}</td>
                        <td>{{ $perawatan->operator->nama ?? '-' }}</td>
                        <td>{{ $detail->alat->nama ?? '-' }}</td>
                        <td>{{ \Carbon\Carbon::parse($detail->tgl_selesai)->format('d-m-Y') }}</td>
                        <td>{{ ucfirst($detail->status) }}</td>
                        <td>{{ $detail->catatan ?? '-' }}</td>
                    </tr>
                @endforeach
            @endforeach
        </tbody>
    </table>

</body>
</html>
