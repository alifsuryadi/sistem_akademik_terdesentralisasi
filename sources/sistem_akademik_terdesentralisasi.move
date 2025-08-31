module sistem_akademik::kampus {
    use std::string::{Self, String};
    use std::vector;
    
    // === ERROR CONSTANTS ===
    const ENIM_INVALID: u64 = 0;
    const ENOT_AUTHORIZED: u64 = 1;
    const EVALUES_INVALID: u64 = 2;
    const ENOT_FOUND: u64 = 3;
    
    // === STRUCTS ===
    
    // Admin capability
    public struct AdminCap has key {
        id: UID,
    }
    
    // Mahasiswa profile (owned object)
    public struct MahasiswaProfile has key, store {
        id: UID,
        nama: String,
        nim: u32,
        jurusan: String,
        semester: u8,
        total_sks: u64,
        ipk: u64, // IPK x 100 (contoh: 350 = 3.50)
        aktif: bool,
        owner: address,
    }
    
    // Registry kampus (shared object)
    public struct KampusRegistry has key {
        id: UID,
        nama_kampus: String,
        total_mahasiswa: u64,
        daftar_nim: vector<u32>,
        admin: address,
    }
    
    // Nilai mata kuliah (owned object)
    public struct NilaiMataKuliah has key, store {
        id: UID,
        nim_mahasiswa: u32,
        kode_mk: String,
        nama_mk: String,
        sks: u8,
        nilai: u8,
        semester: u8,
        tahun: u16,
    }
    
    // === EVENTS ===
    public struct MahasiswaRegistered has copy, drop {
        nim: u32,
        nama: String,
        jurusan: String,
    }
    
    public struct NilaiAdded has copy, drop {
        nim: u32,
        mata_kuliah: String,
        nilai: u8,
        sks: u8,
    }
    
    // === INIT FUNCTION ===
    fun init(ctx: &mut TxContext) {
        // Buat admin capability
        let admin_cap = AdminCap {
            id: object::new(ctx),
        };
        
        // Buat kampus registry
        let registry = KampusRegistry {
            id: object::new(ctx),
            nama_kampus: string::utf8(b"Universitas Blockchain Indonesia"),
            total_mahasiswa: 0,
            daftar_nim: vector::empty<u32>(),
            admin: tx_context::sender(ctx),
        };
        
        // Transfer admin cap ke deployer
        transfer::transfer(admin_cap, tx_context::sender(ctx));
        
        // Share registry untuk akses publik
        transfer::share_object(registry);
    }
    
    // === ADMIN FUNCTIONS ===
    
    // Register mahasiswa baru (hanya admin)
    public fun register_mahasiswa(
        _: &AdminCap, // Admin capability sebagai authorization
        registry: &mut KampusRegistry,
        nama: String,
        nim: u32,
        jurusan: String,
        mahasiswa_address: address,
        ctx: &mut TxContext
    ) {
        // Validasi NIM
        assert!(nim >= 20000000 && nim <= 29999999, ENIM_INVALID);
        
        // Buat profile mahasiswa
        let profile = MahasiswaProfile {
            id: object::new(ctx),
            nama: nama,
            nim,
            jurusan: jurusan,
            semester: 1,
            total_sks: 0,
            ipk: 0,
            aktif: true,
            owner: mahasiswa_address,
        };
        
        // Update registry
        registry.total_mahasiswa = registry.total_mahasiswa + 1;
        vector::push_back(&mut registry.daftar_nim, nim);
        
        // Emit event
        sui::event::emit(MahasiswaRegistered {
            nim,
            nama,
            jurusan,
        });
        
        // Transfer profile ke mahasiswa
        transfer::transfer(profile, mahasiswa_address);
    }
    
    // Berikan nilai (hanya admin)
    public fun beri_nilai(
        _: &AdminCap,
        kode_mk: String,
        nama_mk: String,
        sks: u8,
        nilai: u8,
        semester: u8,
        tahun: u16,
        nim_mahasiswa: u32,
        mahasiswa_address: address,
        ctx: &mut TxContext
    ) {
        // Validasi
        assert!(nilai <= 100, EVALUES_INVALID);
        assert!(sks >= 1 && sks <= 6, EVALUES_INVALID);
        
        let nilai_mk = NilaiMataKuliah {
            id: object::new(ctx),
            nim_mahasiswa,
            kode_mk: kode_mk,
            nama_mk: nama_mk,
            sks,
            nilai,
            semester,
            tahun,
        };
        
        // Emit event
        sui::event::emit(NilaiAdded {
            nim: nim_mahasiswa,
            mata_kuliah: nama_mk,
            nilai,
            sks,
        });
        
        // Transfer ke mahasiswa
        transfer::transfer(nilai_mk, mahasiswa_address);
    }
    
    // === MAHASISWA FUNCTIONS ===
    
    // Update profile sendiri
    public fun update_semester(
        profile: &mut MahasiswaProfile,
        semester_baru: u8,
        ctx: &TxContext
    ) {
        assert!(profile.owner == tx_context::sender(ctx), ENOT_AUTHORIZED);
        assert!(semester_baru >= profile.semester, EVALUES_INVALID);
        
        profile.semester = semester_baru;
    }
    
    // Update IPK berdasarkan nilai yang dimiliki
    public fun hitung_ipk(
        profile: &mut MahasiswaProfile,
        daftar_nilai: &vector<NilaiMataKuliah>,
        ctx: &TxContext
    ) {
        assert!(profile.owner == tx_context::sender(ctx), ENOT_AUTHORIZED);
        
        let mut total_nilai_tertimbang = 0u64;
        let mut total_sks = 0u64;
        let mut i = 0;
        
        let len = vector::length(daftar_nilai);
        while (i < len) {
            let nilai_mk = vector::borrow(daftar_nilai, i);
            
            // Hanya hitung nilai untuk mahasiswa ini
            if (nilai_mk.nim_mahasiswa == profile.nim) {
                // Konversi nilai ke point (A=4, B=3, C=2, D=1, E=0)
                let point = if (nilai_mk.nilai >= 80) 4
                           else if (nilai_mk.nilai >= 70) 3
                           else if (nilai_mk.nilai >= 60) 2
                           else if (nilai_mk.nilai >= 50) 1
                           else 0;
                
                total_nilai_tertimbang = total_nilai_tertimbang + (point * (nilai_mk.sks as u64));
                total_sks = total_sks + (nilai_mk.sks as u64);
            };
            
            i = i + 1;
        };
        
        // Update profile
        profile.total_sks = total_sks;
        if (total_sks > 0) {
            profile.ipk = (total_nilai_tertimbang * 100) / total_sks; // IPK x 100
        };
    }
    
    // === VIEW FUNCTIONS ===
    
    // Get info mahasiswa
    public fun get_mahasiswa_info(profile: &MahasiswaProfile): (String, u32, String, u8, u64, u64, bool) {
        (
            profile.nama,
            profile.nim,
            profile.jurusan,
            profile.semester,
            profile.total_sks,
            profile.ipk,
            profile.aktif
        )
    }
    
    // Get info kampus
    public fun get_kampus_info(registry: &KampusRegistry): (String, u64) {
        (registry.nama_kampus, registry.total_mahasiswa)
    }
    
    // Cek syarat kelulusan
    public fun cek_kelulusan(profile: &MahasiswaProfile): bool {
        profile.total_sks >= 144 && profile.ipk >= 200 && profile.aktif
    }
    
    // Get detail nilai
    public fun get_nilai_info(nilai: &NilaiMataKuliah): (u32, String, String, u8, u8) {
        (
            nilai.nim_mahasiswa,
            nilai.kode_mk,
            nilai.nama_mk,
            nilai.sks,
            nilai.nilai
        )
    }
}