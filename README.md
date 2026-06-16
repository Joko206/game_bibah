# Game Bibah

Proyek Roblox ini dikelola menggunakan [Rojo](https://github.com/rojo-rbx/rojo).

## 🚀 Cara Setup Pertama Kali (Pengguna Windows)

Jika Anda baru saja mendapatkan kode sumber proyek ini di komputer baru, Anda tidak perlu menginstal alat (*tools*) secara manual. Cukup ikuti langkah berikut:

1. Buka folder proyek ini.
2. Cari dan **klik ganda (*double-click*)** pada file `setup.bat`.
3. Biarkan script berjalan. Script ini akan otomatis mengunduh dan menginstal Aftman beserta Rojo versi yang tepat.
4. Setelah muncul tulisan "Setup Selesai!", tekan sembarang tombol untuk menutup jendela.
5. **Sangat Penting:** Tutup dan buka kembali Visual Studio Code atau PowerShell Anda agar komputer mengenali program yang baru diinstal.

### 🍎/🐧 Pengguna Mac & Linux
Jika Anda menggunakan Mac atau Linux, buka Terminal dan jalankan perintah Aftman manual:
```bash
# Instal Aftman (menggunakan curl/wget dari repo github LPGhatguy/aftman)
# Pastikan aftman masuk ke dalam PATH Anda
aftman install
```

---

## 🛠️ Cara Mem-build dan Menjalankan Proyek

Setelah proses *setup* selesai, Anda bisa membuat file game Roblox (`.rbxlx`) dengan perintah:

```bash
rojo build -o "game bibah.rbxlx"
```

**Langkah selanjutnya (Live Sync):**
1. Buka file `game bibah.rbxlx` yang baru saja terbuat di **Roblox Studio**.
2. Untuk mulai menulis kode dan melihat perubahannya langsung masuk ke Roblox Studio, jalankan server Rojo:

```bash
rojo serve
```
*(Atau jika Anda menggunakan ekstensi Rojo di VS Code, Anda cukup menekan tombol "Rojo" di pojok kanan bawah VS Code Anda).*

---
Untuk info lebih lengkap tentang Rojo, silakan baca [Dokumentasi Resmi Rojo](https://rojo.space/docs).