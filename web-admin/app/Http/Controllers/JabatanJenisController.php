<?php

namespace App\Http\Controllers;

use App\Models\JenisAlat;
use App\Models\Role;
use Illuminate\Http\Request;

class JabatanJenisController extends Controller
{
    public function jabatanIndex()
    {
        $roles = Role::all();
        return view('pages.jabatan.index', compact('roles'));
    }

    public function jenisIndex()
    {
        $jenis = JenisAlat::all();
        return view('pages.jenis.index', compact('jenis'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'type' => 'required|in:jabatan,jenis',
            'nama' => 'required|string|max:50'
        ]);

        if ($request->type === 'jabatan') {
            Role::create(['jabatan' => $request->nama]);
            return redirect()->route('jabatan.index')->with('success', 'Jabatan berhasil ditambahkan.');
        } else {
            JenisAlat::create(['nama' => $request->nama]);
            return redirect()->route('jenis.index')->with('success', 'Jenis alat berhasil ditambahkan.');
        }
    }

    public function update(Request $request, $type, $id)
    {
        $request->validate(['nama' => 'required|string|max:50']);

        if ($type === 'jabatan') {
            $jabatan = Role::findOrFail($id);
            $jabatan->update(['jabatan' => $request->nama]);
            return redirect()->route('jabatan.index')->with('success', 'Jabatan berhasil diubah.');
        } else {
            $jenis = JenisAlat::findOrFail($id);
            $jenis->update(['nama' => $request->nama]);
            return redirect()->route('jenis.index')->with('success', 'Jenis alat berhasil diubah.');
        }
    }

    public function destroy($type, $id)
    {
        if ($type === 'jabatan') {
            Role::destroy($id);
            return redirect()->route('jabatan.index')->with('success', 'Jabatan berhasil dihapus.');
        } else {
            JenisAlat::destroy($id);
            return redirect()->route('jenis.index')->with('success', 'Jenis alat berhasil dihapus.');
        }
    }
}
