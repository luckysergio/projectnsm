<div class="modal fade" id="confirmationDelete-{{ $item->id }}" tabindex="-1" aria-labelledby="confirmationDeleteLabel"
    aria-hidden="true">
    <div class="modal-dialog">
        <form action="/Inventory/{{ $item->id }}" method="post">
            @csrf
            @method('DELETE')
            <div class="modal-content">
                <div class="modal-header">
                    <h1 class="modal-title fs-5" id="confirmationDeleteLabel">Konfirmasi Hapus</h1>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <span>Apakah anda yakin untuk menghapus data ini ?</span>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-danger">Ya, Hapus!</button>
                </div>
            </div>
        </form>
    </div>
</div>

<style>
    .modal-dialog {
        display: flex;
        align-items: center;
        justify-content: center;
        min-height: 100vh;
    }
</style>