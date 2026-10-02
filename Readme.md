Tahap 1 : Mengamati Masalah Layout yang Tidak Responsif

Dari percobaan ini saya menemukan bahwa penggunaan width: 500 membuat tampilan mengalami overflow saat dijalankan di layar HP yang lebih kecil. Setelah width diganti menjadi double.infinity, Container bisa mengikuti ruang yang tersedia sehingga tampilan menjadi lebih rapi. Jadi, ukuran yang terlalu tetap kurang cocok digunakan untuk tampilan yang harus menyesuaikan berbagai ukuran layar.

Tahap 2 : MediaQuery: Membaca Karakteristik Layar

Pada tahap ini saya mencoba menggunakan MediaQuery untuk melihat ukuran dan orientasi layar. Hasilnya, nilai width dan height berubah ketika emulator diputar dari portrait ke landscape. Saya juga mencoba kondisi width < 600 untuk membedakan tampilan Compact dan Wide. Dari sini saya jadi memahami bahwa ukuran layar bisa digunakan sebagai acuan untuk mengatur tampilan aplikasi agar menyesuaikan device.

Tahap 3 : LayoutBuilder dan Breakpoint

Pada tahap ini saya mencoba menggunakan LayoutBuilder untuk menyesuaikan tampilan berdasarkan lebar ruang yang tersedia. Hasilnya, layout dapat berubah dari Compact, Medium, sampai Expanded ketika ukuran window diperbesar. Saya juga melihat bahwa LayoutBuilder berbeda dengan MediaQuery, karena LayoutBuilder lebih fokus pada ruang yang tersedia untuk widget tersebut, bukan hanya ukuran layar secara keseluruhan.