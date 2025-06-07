<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model {
    use HasFactory;

    protected $fillable = [
        'sales_id', 'nama_pemesan', 'alamat_pemesan', 'inventori_id',
        'total_sewa','overtime','harga_sewa','denda','total_harga', 'status_pembayaran', 'status_order',
        'tgl_pemakaian','jam_berangkat','jam_mulai','jam_selesai', 'tgl_pengembalian', 'operator_name', 'catatan'
    ];

    // **Menyembunyikan ID yang tidak diperlukan di JSON response**
    protected $hidden = [
        'sales', 'inventori', // Sembunyikan relasi asli agar tidak muncul nested object
        'sales_id', 'inventori_id', // Sembunyikan ID terkait
        'created_at', 'updated_at' // Opsional: Sembunyikan timestamp jika tidak perlu
    ];

    // **Menambahkan kolom baru di JSON response**
    protected $appends = ['sales_name', 'inventori_name'];

    // **Relasi ke User (Sales)**
    public function sales() {
        return $this->belongsTo(User::class, 'sales_id');
    }

    // **Relasi ke Inventori (Alat)**
    public function inventori() {
        return $this->belongsTo(Inventory::class, 'inventori_id');
    }

    // **Accessor untuk Nama Sales dengan Fallback**
    public function getSalesNameAttribute() {
        return $this->sales?->name ?? 'Unknown Sales';
    }

    // **Accessor untuk Nama Inventori (Alat) dengan Fallback**
    public function getInventoriNameAttribute() {
        return $this->inventori?->nama_alat ?? 'Unknown Alat';
    }

    // **Scope untuk Order Berdasarkan Status**
    public function scopeByStatus($query, $status)
    {
        return $query->where('status_order', $status);
    }

    // **Scope untuk Order Milik Sales Tertentu**
    public function scopeBySales($query, $salesId)
    {
        return $query->where('sales_id', $salesId);
    }

    // **Method untuk Mengambil Semua ID dari Collection Order**
    public static function getOrderIds($salesId, $status = null)
    {
        $query = self::where('sales_id', $salesId);
        if ($status) {
            $query->where('status_order', $status);
        }
        return $query->pluck('id'); // ✅ Mengambil hanya ID
    }

    public function orderDocuments()
    {
        return $this->hasMany(OrderDocument::class);
    }
}
