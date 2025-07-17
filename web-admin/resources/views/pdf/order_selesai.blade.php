<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Laporan Sewa</title>
    <style>
        body {
            font-family: sans-serif;
            font-size: 12px;
            color: #333;
        }

        .header {
            text-align: center;
            margin-bottom: 20px;
        }

        .header h2 {
            margin: 0;
            font-size: 18px;
        }

        .header p {
            margin: 0;
            font-size: 13px;
            color: #555;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 25px;
        }

        th, td {
            border: 1px solid #999;
            padding: 6px 8px;
            text-align: left;
            vertical-align: top;
        }

        th {
            background-color: #f2f2f2;
        }

        .total {
            text-align: right;
            font-weight: bold;
            margin-top: 15px;
        }

        .footer {
            position: fixed;
            bottom: 10px;
            left: 0;
            right: 0;
            text-align: center;
            font-size: 10px;
            color: #999;
        }
        .total {
            text-align: center;
            font-weight: bold;
            margin-top: 20px;
            font-size: 14px;
        }
    </style>
</head>
<body>

    @php
        use Carbon\Carbon;

        $bulan = request('bulan');
        $tahun = request('tahun');

        $periode = 'Semua Periode';
        if ($bulan && $tahun) {
            $periode = Carbon::createFromDate($tahun, $bulan)->translatedFormat('F Y');
        } elseif ($tahun) {
            $periode = 'Tahun ' . $tahun;
        }
    @endphp

    <div class="header">
        <h2>LAPORAN SEWA</h2>
        <p>Periode: {{ $periode }}</p>
    </div>

    @foreach ($orders as $order)
        <table>
            <tr>
                <th colspan="4">NSM-SEWA-00{{ $order->id }}</th>
            </tr>
            <tr>
                <td><strong>Nama Pelanggan:</strong> {{ $order->customer->nama ?? '-' }}</td>
                <td><strong>Sales:</strong> {{ $order->sales->nama ?? '-' }}</td>
                <td><strong>Tanggal Order:</strong> {{ $order->created_at->format('d-m-Y') }}</td>
                <td><strong>Tagihan:</strong> Rp{{ number_format($order->pembayaran->tagihan ?? 0) }}</td>
            </tr>

            @if ($order->detailOrders->count())
                <tr>
                    <th colspan="4">Detail Order</th>
                </tr>
                @foreach ($order->detailOrders as $detail)
                    <tr>
                        <td colspan="2">
                            Alat: {{ $detail->alat->nama ?? '-' }}<br>
                            Alamat: {{ $detail->alamat }}<br>
                        </td>
                        <td colspan="2">
                            Total Sewa: {{ number_format($detail->total_sewa) }} Jam<br>
                            Status: {{ ucfirst($detail->status) }}
                        </td>
                    </tr>
                @endforeach
            @endif

            @php
                $detailPembayarans = $order->pembayaran->detailPembayarans ?? collect();
            @endphp

            @if ($detailPembayarans->count())
                <tr>
                    <th colspan="4">Detail Pembayaran</th>
                </tr>
                <tr>
                    <th>No</th>
                    <th>Tanggal</th>
                    <th>Jumlah Dibayar</th>
                    <th>Bukti</th>
                </tr>
                @foreach ($detailPembayarans as $index => $dp)
                    <tr>
                        <td>{{ $index + 1 }}</td>
                        <td>{{ $dp->created_at->format('d-m-Y') }}</td>
                        <td>Rp{{ number_format($dp->jml_dibayar) }}</td>
                        <td>
                            @if ($dp->bukti)
                                <a href="{{ asset('storage/' . $dp->bukti) }}" target="_blank">Lihat</a>
                            @else
                                <em>Tidak Ada</em>
                            @endif
                        </td>
                    </tr>
                @endforeach
            @else
                <tr>
                    <td colspan="4"><em>Belum ada pembayaran.</em></td>
                </tr>
            @endif
        </table>
    @endforeach

    <div class="total">
        Total Pendapatan: <strong>Rp{{ number_format($totalPendapatan) }}</strong>
    </div>

    <div class="footer">
        Dicetak oleh Sistem - {{ now()->format('d/m/Y H:i') }}
    </div>
</body>
</html>
