# Cursor Hack

Script untuk memodifikasi machine ID dan telemetry data Cursor untuk menghindari batasan trial.

## Instalasi

### Linux
1. Buka terminal
2. Download dan install script:
```bash
curl -fsSL https://aku-es.tech/cursor/new.sh -o ~/.local/bin/fakem && chmod +x ~/.local/bin/fakem
```
3. Pastikan `~/.local/bin` ada di PATH. Jika belum, tambahkan baris berikut ke `~/.bashrc` atau `~/.zshrc`:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Penggunaan

```bash
fakem {on|off|new|gen|run}
```

### Perintah yang tersedia:
- `on` - Aktifkan fake machine ID
- `off` - Nonaktifkan fake machine ID
- `new` - Generate fake machine ID baru
- `gen` - Generate data telemetry baru dan update storage.json
- `run` - Jalankan aplikasi dengan fake machine ID

## Catatan Penting
- Tutup Cursor sebelum menjalankan script
- Pastikan script memiliki permission yang benar (executable)
