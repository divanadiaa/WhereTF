# WhereToFind Mobile - Instruksi Project

## Catatan Nama Project

Nama aplikasi saat ini adalah "WhereToFind", namun nama ini masih bersifat sementara dan dapat berubah di masa depan.

Untuk dokumentasi internal dan pengembangan, project mobile ini dapat disebut sebagai:

- WhereToFind Mobile
- WhereToFind App

## Gambaran Umum Project

WhereToFind adalah aplikasi mobile berbagi lokasi yang secara konsep mirip dengan Life360.

Aplikasi memungkinkan pengguna:

- membuat circle/group privat
- bergabung ke circle/group
- berbagi lokasi real-time dengan anggota terpercaya
- melihat lokasi anggota circle
- mengakses fitur premium tertentu seperti location history

Mobile app dibuat menggunakan Flutter dan terhubung ke backend Laravel melalui REST API.

Realtime update lokasi dapat menggunakan Firebase Realtime Database atau Cloud Firestore sesuai implementasi backend yang sudah ada.

## Tech Stack

- Flutter
- Dart
- REST API
- Laravel Backend
- Firebase Realtime Database atau Cloud Firestore
- PostgreSQL + PostGIS di backend
- Redis di backend
- JSON API Response

## Tujuan Mobile App

Mobile app bertanggung jawab untuk:

- menampilkan UI aplikasi
- login/register user
- menyimpan token autentikasi
- mengakses REST API backend
- mengirim update lokasi user
- menerima update lokasi real-time
- menampilkan map dan member location
- menampilkan status premium/subscription
- menangani loading, error, dan permission state

Business logic utama tetap berada di backend.

Mobile app tidak boleh menggantikan validasi utama backend.

## Struktur Project Flutter

Ikuti struktur project yang sudah ada.

Jangan melakukan refactor besar atau mengganti architecture tanpa instruksi eksplisit.
