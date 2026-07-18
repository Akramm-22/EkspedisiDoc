# Panduan Deployment Docker — drgEkspedisi

Arsitektur: Client → Nginx Load Balancer → 3 container Web (image yang sama) → MySQL.

## 1. Prasyarat

- Docker Engine ≥ 24 dan Docker Compose plugin (`docker compose version`).
- Port `8000` di host kosong (bisa diganti lewat `APP_PORT`).
- File project ini lengkap (termasuk folder `docker/`, `Dockerfile`, `docker-compose.yml`, `.env.docker`).

## 2. Konfigurasi `.env.docker`

File `.env.docker` sudah disediakan dengan nilai default untuk deployment (DB, session, cache, dsb). Yang **wajib** kamu isi sebelum deploy pertama kali:

1. `APP_KEY` — lihat langkah 3.
2. `MIDTRANS_MERCHANT_ID`, `MIDTRANS_SERVER_KEY`, `MIDTRANS_CLIENT_KEY` — dari dashboard Midtrans.
3. `RECAPTCHA_SITE_KEY`, `RECAPTCHA_SECRET_KEY` — dari Google reCAPTCHA admin console.
4. `MAIL_USERNAME`, `MAIL_PASSWORD` — kredensial SMTP untuk email verifikasi.
5. (Opsional) `DB_PASSWORD`, `DB_ROOT_PASSWORD` — ganti dari default untuk produksi sungguhan.

## 3. Build image & generate APP_KEY

```bash
# Build image web (dipakai oleh web1, web2, web3)
docker compose build

# Generate APP_KEY pakai container sementara, lalu salin hasilnya ke .env.docker
docker compose run --rm web1 php artisan key:generate --show
```

Salin output (mis. `base64:xxxxx...`) ke baris `APP_KEY=` di `.env.docker`.

## 4. Jalankan semua container

```bash
docker compose up -d
```

> Kalau `docker compose version` kamu lebih lama dari v2.24, tambahkan flag
> `--env-file .env.docker` di setiap perintah `docker compose` (termasuk
> `build`, `up`, `run`, `exec`) supaya variabel seperti `MYSQL_DATABASE`
> dan `APP_PORT` terbaca dengan benar:
> `docker compose --env-file .env.docker up -d`

Ini akan menyalakan: `drgekspedisi_mysql`, `drgekspedisi_web1/2/3`, dan `drgekspedisi_lb`.

Container web otomatis (lewat `docker/entrypoint.sh`) saat start:
- Menunggu MySQL siap.
- Menjalankan `php artisan migrate --force` (hanya sekali, dikunci lewat file lock di volume `storage/` supaya 3 container tidak migrate bersamaan).
- Membuat `storage:link` di masing-masing container.
- Menjalankan `config:cache`, `route:cache`, `view:cache`.

## 5. Migrasi & seeder manual (jika perlu ulang)

```bash
docker compose exec web1 php artisan migrate --force
docker compose exec web1 php artisan db:seed --force   # kalau ada seeder
```

## 6. Storage link & permission (jika perlu ulang manual)

```bash
docker compose exec web1 php artisan storage:link
docker compose exec web1 chown -R www-data:www-data storage bootstrap/cache
```

## 7. Verifikasi semua container jalan

```bash
docker compose ps
```

Semua service harus berstatus `Up` / `healthy`. Cek juga:

```bash
docker compose logs -f loadbalancer
docker compose logs -f web1
```

## 8. Test aplikasi

```bash
curl -I http://localhost:8000/up        # health check Laravel (harus 200)
curl -I http://localhost:8000/          # landing page (harus 200)
curl http://localhost:8000/nginx-health # health check load balancer
```

Buka `http://localhost:8000` di browser — cek landing page, login admin/cashier/courier, kirim paket dari sisi customer, cek tracking publik, dan proses pembayaran Midtrans.

Untuk membuktikan load balancing bekerja, tambahkan header debug sementara di masing-masing `docker/nginx.web.conf` (`add_header X-Served-By web1;`) lalu rebuild — atau lihat kolom `upstream=` di log load balancer:

```bash
docker compose logs loadbalancer | grep upstream=
```

## 9. Menghentikan / menghapus

```bash
docker compose down          # stop, volume tetap ada (data DB & storage aman)
docker compose down -v       # stop + hapus semua volume (DATA HILANG)
```

## 10. Troubleshooting

| Gejala | Penyebab umum | Solusi |
|---|---|---|
| `docker compose up` gagal, web keluar langsung | `APP_KEY` kosong | Isi `APP_KEY` di `.env.docker` (lihat langkah 3) |
| Web container restart terus / unhealthy | MySQL belum siap / migrasi gagal | `docker compose logs web1`, pastikan `mysql` healthy dulu |
| Upload foto shipment tidak muncul di browser | `storage:link` belum jalan di container itu | `docker compose exec web1 php artisan storage:link` |
| 502 Bad Gateway dari load balancer | Salah satu web container down | `docker compose ps`, restart container yang unhealthy |
| Error permission di `storage/` atau `bootstrap/cache` | Volume baru dibuat root-owned | `docker compose exec web1 chown -R www-data:www-data storage bootstrap/cache` |
| Login/session sering ke-logout berpindah request | Volume `storage_data` tidak ke-mount di semua container | Pastikan `docker-compose.yml` tidak diubah bagian `volumes:` pada `x-web-common` |
| Midtrans / reCAPTCHA gagal | Kredensial kosong/salah di `.env.docker` | Isi kredensial asli, lalu `docker compose up -d --force-recreate web1 web2 web3` |
| Perubahan `.env.docker` tidak kebaca | Config sudah di-cache | `docker compose exec web1 php artisan config:clear && php artisan config:cache` |

## Catatan Desain

- **1 image, 3 container**: `web1`, `web2`, `web3` dibangun dari `Dockerfile` yang sama (bukan `docker compose up --scale`), supaya nginx load balancer bisa mengarah ke hostname yang pasti dan stabil.
- **Session & cache**: pakai driver `file`, aman karena `storage/` adalah satu named volume yang dipakai bersama oleh ketiga container — jadi tidak ada konflik session antar container di belakang load balancer.
- **Migrasi**: dijalankan otomatis oleh container yang pertama kali start, dikunci dengan `flock` supaya tidak dobel.
- **Setiap web container** menjalankan nginx + php-fpm + 1 queue worker (lewat `supervisord`), jadi kirim-notifikasi/queue tetap jalan walau salah satu container mati.
