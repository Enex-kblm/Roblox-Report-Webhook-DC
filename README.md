# Sistem Report Roblox

Sistem report sederhana untuk game Roblox dengan fitur anti-spam dan integrasi Discord webhook.

## Fitur

- 🔒 Anti-spam protection dengan cooldown 30 detik
- 🐛 Report bug map dengan koordinat otomatis
- 👤 Report player dengan alasan
- 🔗 Kirim report ke Discord via webhook
- 🎨 UI modern dengan animasi

## Instalasi

### 1. Setup RemoteEvent
Buat 2 RemoteEvent di ReplicatedStorage:
- `ReportEvent`
- `AntiSpamEvent`

### 2. Konfigurasi Discord Webhook
Edit bagian ini di script server:
```lua
local WEBHOOK_BUG = "URL_WEBHOOK_DISCORD_ANDA"
local WEBHOOK_PLAYER = "URL_WEBHOOK_DISCORD_ANDA"
```

## Cara Pakai

1. **Buka Report Menu**: Klik tombol "🔥 Report"
2. **Pilih Jenis Report**: Bug Map atau Player
3. **Isi Form**: Masukkan deskripsi/alasan
4. **Kirim**: Report akan dikirim ke Discord

## Anti-Spam

- Cooldown 30 detik antar report
- Deteksi report duplikat otomatis
- Progressive penalty untuk spammer
- Silent logging untuk monitoring

## File Structure

```
/
├─ ReplicatedStorage
│  ├─ AntiSpamEvent
│  └─ ReportEvent
├─ ServerScriptService
│  └─ Script.lua
└─ StarterGui
   └─ ScreenGui
      └─ LocalScript.lua
```

## Konfigurasi

```lua
-- Durasi cooldown (detik)
local COOLDOWN = 30

-- Threshold similarity untuk deteksi duplikat
local SIMILARITY_THRESHOLD = 0.7
```

## Discord Output

Report akan muncul di Discord dengan format:
- **Bug Report**: Koordinat, deskripsi, server ID
- **Player Report**: Target, alasan, server ID

## License

MIT License - bebas digunakan dan dimodifikasi.
