# 🖱️

## Instalasi

### Linux
1. Buka terminal
2. Download dan install script:
```bash
curl -fsSL https://raw.githubusercontent.com/se7uh/cursr/refs/heads/main/new.sh -o ~/.local/bin/fakem && chmod +x ~/.local/bin/fakem
```
3. Pastikan `~/.local/bin` ada di PATH. Jika belum, tambahkan baris berikut ke `~/.bashrc` atau `~/.zshrc`:
```bash
export PATH="$HOME/.local/bin:$PATH"
```
4. Untuk fitur date spoofing, install `faketime`:
```bash
# Debian/Ubuntu
sudo apt-get install faketime

# Fedora
sudo dnf install faketime

# Arch Linux
sudo pacman -S faketime
```

## Penggunaan

```bash
fakem {on|off|new|gen|beta|settings|reset|run|update|version}
```

### Perintah yang tersedia:
- `on` - Aktifkan fake machine ID
- `off` - Nonaktifkan fake machine ID
- `new` - Generate fake machine ID baru
- `gen` - Generate data telemetry baru dan update storage.json
- `beta` - Generate data telemetry format beta (simplified format)
- `settings` - Konfigurasi tanggal dan pengaturan lainnya
- `reset` - Reset semua ID (machine ID dan telemetry)
- `run` - Jalankan aplikasi dengan fake machine ID dan fake date
- `update` - Perbarui script ke versi terbaru
- `version` - Tampilkan informasi versi

## Fitur Settings
Script ini sekarang menggunakan file JSON untuk menyimpan pengaturan di `~/.fakem.json`:
- Fake machine ID disimpan dalam settings, bukan lagi di file terpisah
- Custom date dapat diatur dan akan digunakan saat menjalankan aplikasi dengan `run`
- Semua pengaturan dapat dikonfigurasi melalui perintah `settings`

## Catatan Penting
- Tutup Cursor sebelum menjalankan script
- Pastikan script memiliki permission yang benar (executable)
- Untuk fitur date spoofing, pastikan `faketime` sudah terinstall
