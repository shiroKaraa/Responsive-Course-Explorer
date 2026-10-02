Tahap 1 : Mengamati Masalah Layout yang Tidak Responsif

Dari percobaan ini saya menemukan bahwa penggunaan width: 500 membuat tampilan mengalami overflow saat dijalankan di layar HP yang lebih kecil. Setelah width diganti menjadi double.infinity, Container bisa mengikuti ruang yang tersedia sehingga tampilan menjadi lebih rapi. Jadi, ukuran yang terlalu tetap kurang cocok digunakan untuk tampilan yang harus menyesuaikan berbagai ukuran layar.


Tahap 2 : MediaQuery: Membaca Karakteristik Layar

Pada tahap ini saya mencoba menggunakan MediaQuery untuk melihat ukuran dan orientasi layar. Hasilnya, nilai width dan height berubah ketika emulator diputar dari portrait ke landscape. Saya juga mencoba kondisi width < 600 untuk membedakan tampilan Compact dan Wide. Dari sini saya jadi memahami bahwa ukuran layar bisa digunakan sebagai acuan untuk mengatur tampilan aplikasi agar menyesuaikan device.