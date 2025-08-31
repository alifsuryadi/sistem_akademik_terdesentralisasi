# Sistem Akademik Terdesentralisasi

Sistem manajemen akademik terdesentralisasi yang dibangun menggunakan Sui Move blockchain. Sistem ini memungkinkan pengelolaan data mahasiswa, nilai, dan administrasi kampus dengan transparansi dan keamanan blockchain.

## Fitur Utama

### 1. Manajemen Mahasiswa

- Registrasi mahasiswa baru oleh admin
- Profil mahasiswa dengan data lengkap (nama, NIM, jurusan, semester)
- Update semester mahasiswa
- Status keaktifan mahasiswa

### 2. Manajemen Nilai

- Input nilai mata kuliah oleh admin
- Perhitungan IPK otomatis berdasarkan nilai
- Konversi nilai ke sistem poin (A=4, B=3, C=2, D=1, E=0)
- Tracking total SKS yang telah ditempuh

### 3. Registry Kampus

- Informasi kampus terpusat
- Daftar seluruh NIM mahasiswa
- Statistik total mahasiswa

### 4. Sistem Otorisasi

- Admin capability untuk fungsi administratif
- Ownership mahasiswa untuk update profil sendiri
- Validasi otorisasi untuk setiap transaksi

## Struktur Data

### AdminCap

Capability yang diberikan kepada admin untuk melakukan operasi administratif.

### MahasiswaProfile

Profil mahasiswa yang berisi:

- `nama`: Nama lengkap mahasiswa
- `nim`: Nomor Induk Mahasiswa (8 digit, 20000000-29999999)
- `jurusan`: Program studi mahasiswa
- `semester`: Semester saat ini
- `total_sks`: Total SKS yang telah ditempuh
- `ipk`: Indeks Prestasi Kumulatif (x100, contoh: 350 = 3.50)
- `aktif`: Status keaktifan mahasiswa
- `owner`: Alamat pemilik profil

### KampusRegistry

Registry terpusat kampus yang berisi:

- `nama_kampus`: Nama institusi
- `total_mahasiswa`: Jumlah total mahasiswa
- `daftar_nim`: Daftar seluruh NIM yang terdaftar
- `admin`: Alamat admin kampus

### NilaiMataKuliah

Record nilai mata kuliah yang berisi:

- `nim_mahasiswa`: NIM pemilik nilai
- `kode_mk`: Kode mata kuliah
- `nama_mk`: Nama mata kuliah
- `sks`: Jumlah SKS mata kuliah
- `nilai`: Nilai numerik (0-100)
- `semester`: Semester pengambilan
- `tahun`: Tahun akademik

## Fungsi Utama

### Fungsi Admin

#### `register_mahasiswa`

Mendaftarkan mahasiswa baru ke sistem.

- Parameter: AdminCap, registry, data mahasiswa, alamat mahasiswa
- Validasi: NIM harus dalam range 20000000-29999999
- Output: MahasiswaProfile ditransfer ke alamat mahasiswa

#### `beri_nilai`

Memberikan nilai mata kuliah kepada mahasiswa.

- Parameter: AdminCap, data mata kuliah, NIM mahasiswa, alamat mahasiswa
- Validasi: Nilai 0-100, SKS 1-6
- Output: NilaiMataKuliah ditransfer ke alamat mahasiswa

### Fungsi Mahasiswa

#### `update_semester`

Update semester mahasiswa (hanya bisa dilakukan oleh pemilik profil).

- Validasi: Semester baru >= semester saat ini
- Otorisasi: Hanya pemilik profil

#### `hitung_ipk`

Menghitung IPK berdasarkan nilai-nilai yang dimiliki.

- Menggunakan sistem poin standar Indonesia
- Menghitung total SKS dan nilai tertimbang
- Update otomatis profil mahasiswa

### Fungsi View

#### `get_mahasiswa_info`

Mengambil informasi lengkap profil mahasiswa.

#### `get_kampus_info`

Mengambil informasi kampus dan statistik.

#### `cek_kelulusan`

Mengecek syarat kelulusan mahasiswa:

- Minimal 144 SKS
- IPK minimal 2.00
- Status aktif

#### `get_nilai_info`

Mengambil detail nilai mata kuliah.

## Persyaratan Sistem

- Sui CLI
- Move compiler
- Git (untuk dependency management)

## Instalasi dan Build

1. Clone repository:

```bash
git clone https://github.com/alifsuryadi/sistem_akademik_terdesentralisasi.git
cd sistem_akademik_terdesentralisasi
```

2. Build project:

```bash
sui move build
```

3. Deploy ke testnet:

```bash
sui client publish --gas-budget 100000000
```

4. Interaksi dengan contract:

```bash
# Cek objects yang dimiliki
sui client objects

# Register mahasiswa (sebagai admin)
sui client call \
  --package <PACKAGE_ID> \
  --module kampus \
  --function register_mahasiswa \
  --args <ADMIN_CAP_ID> <REGISTRY_ID> "Budi Santoso" 20230001 "Teknik Informatika" <STUDENT_ADDRESS> \
  --gas-budget 10000000

# Lihat info kampus
sui client call \
  --package <PACKAGE_ID> \
  --module kampus \
  --function get_kampus_info \
  --args <REGISTRY_ID> \
  --gas-budget 1000000
```

## Contract yang Sudah Di-Deploy

Contract telah berhasil di-deploy di Sui testnet dengan informasi berikut:

- **Package ID**: `0x569451806843e74b8ce15ae1e1da0dc4618c07958f9688378952b4c4f34f6adf`
- **Admin Cap ID**: `0x7cc96cac863476916f5392cd019d09c49a2bf61e427537b916711cff8d263975`
- **Kampus Registry ID**: `0x448b933cf7e3bfa179acc9cc20a868608002d1628207cd813282603f2b3f3a43`
- **Transaction Digest**: `4zDSaVmnCeHoSpqcCbvqBBDF3Envdz4ojq7hP5odfh8D`

## Cara Menggunakan Contract yang Sudah Di-Deploy

### 1. Registrasi Mahasiswa Baru (Admin Only)

```bash
sui client call \
  --package 0x569451806843e74b8ce15ae1e1da0dc4618c07958f9688378952b4c4f34f6adf \
  --module kampus \
  --function register_mahasiswa \
  --args 0x7cc96cac863476916f5392cd019d09c49a2bf61e427537b916711cff8d263975 0x448b933cf7e3bfa179acc9cc20a868608002d1628207cd813282603f2b3f3a43 "Budi Santoso" 20230001 "Teknik Informatika" 0xALAMAT_MAHASISWA \
  --gas-budget 10000000
```

### 2. Lihat Informasi Kampus

```bash
sui client call \
  --package 0x569451806843e74b8ce15ae1e1da0dc4618c07958f9688378952b4c4f34f6adf \
  --module kampus \
  --function get_kampus_info \
  --args 0x448b933cf7e3bfa179acc9cc20a868608002d1628207cd813282603f2b3f3a43 \
  --gas-budget 1000000
```

### 3. Input Nilai Mata Kuliah (Admin Only)

```bash
sui client call \
  --package 0x569451806843e74b8ce15ae1e1da0dc4618c07958f9688378952b4c4f34f6adf \
  --module kampus \
  --function beri_nilai \
  --args 0x7cc96cac863476916f5392cd019d09c49a2bf61e427537b916711cff8d263975 "IF101" "Pemrograman Dasar" 3 85 1 2024 20230001 0xALAMAT_MAHASISWA \
  --gas-budget 10000000
```

### 4. Update Semester Mahasiswa

```bash
sui client call \
  --package 0x569451806843e74b8ce15ae1e1da0dc4618c07958f9688378952b4c4f34f6adf \
  --module kampus \
  --function update_semester \
  --args 0xPROFILE_MAHASISWA_ID 2 \
  --gas-budget 5000000
```

### 5. Hitung IPK Mahasiswa

```bash
sui client call \
  --package 0x569451806843e74b8ce15ae1e1da0dc4618c07958f9688378952b4c4f34f6adf \
  --module kampus \
  --function hitung_ipk \
  --args 0xPROFILE_MAHASISWA_ID "[0xNILAI_MK_ID1,0xNILAI_MK_ID2]" \
  --gas-budget 10000000
```

### 6. Cek Status Kelulusan Mahasiswa

```bash
sui client call \
  --package 0x569451806843e74b8ce15ae1e1da0dc4618c07958f9688378952b4c4f34f6adf \
  --module kampus \
  --function cek_kelulusan \
  --args 0xPROFILE_MAHASISWA_ID \
  --gas-budget 1000000
```

### 7. Lihat Detail Profil Mahasiswa

```bash
sui client call \
  --package 0x569451806843e74b8ce15ae1e1da0dc4618c07958f9688378952b4c4f34f6adf \
  --module kampus \
  --function get_mahasiswa_info \
  --args 0xPROFILE_MAHASISWA_ID \
  --gas-budget 1000000
```

### 8. Lihat Detail Nilai Mata Kuliah

```bash
sui client call \
  --package 0x569451806843e74b8ce15ae1e1da0dc4618c07958f9688378952b4c4f34f6adf \
  --module kampus \
  --function get_nilai_info \
  --args 0xNILAI_MK_ID \
  --gas-budget 1000000
```

### Catatan Penggunaan:

- Ganti `0xALAMAT_MAHASISWA` dengan alamat wallet mahasiswa yang sesungguhnya
- Ganti `0xPROFILE_MAHASISWA_ID` dengan ID profil mahasiswa yang sudah terdaftar
- Ganti `0xNILAI_MK_ID` dengan ID nilai mata kuliah yang ingin dilihat
- Hanya pemilik AdminCap yang dapat melakukan registrasi mahasiswa dan input nilai
- Mahasiswa hanya bisa mengakses dan mengubah profil mereka sendiri

### Melihat Objects yang Dimiliki

```bash
# Cek semua objects yang dimiliki account Anda
sui client objects

# Cek objects berdasarkan type tertentu
sui client objects --filter StructType=0x569451806843e74b8ce15ae1e1da0dc4618c07958f9688378952b4c4f34f6adf::kampus::MahasiswaProfile
```

## Penggunaan

### 1. Deploy Contract

Setelah deploy, admin akan mendapatkan AdminCap dan KampusRegistry akan menjadi shared object.

### 2. Registrasi Mahasiswa

Admin menggunakan fungsi `register_mahasiswa` untuk mendaftarkan mahasiswa baru.

### 3. Input Nilai

Admin menggunakan fungsi `beri_nilai` untuk memberikan nilai mata kuliah.

### 4. Update Profil

Mahasiswa dapat menggunakan fungsi `update_semester` dan `hitung_ipk` untuk mengelola profil mereka.

## Keamanan

- Semua fungsi admin memerlukan AdminCap sebagai otorisasi
- Mahasiswa hanya dapat mengakses dan memodifikasi profil mereka sendiri
- Validasi input ketat untuk mencegah data tidak valid
- Immutable records untuk transparansi nilai

## Testing

Untuk menjalankan test:

```bash
sui move test
```

## Kontribusi

1. Fork repository
2. Buat branch fitur baru
3. Commit perubahan
4. Push ke branch
5. Buat Pull Request

## Lisensi

Project ini menggunakan lisensi MIT.

## Kontak

Untuk pertanyaan atau dukungan, silakan buka issue di repository ini.
