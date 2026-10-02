Tahap 1 : Mengamati Masalah Layout yang Tidak Responsif

Dari percobaan ini saya menemukan bahwa penggunaan width: 500 membuat tampilan mengalami overflow saat dijalankan di layar HP yang lebih kecil. Setelah width diganti menjadi double.infinity, Container bisa mengikuti ruang yang tersedia sehingga tampilan menjadi lebih rapi. Jadi, ukuran yang terlalu tetap kurang cocok digunakan untuk tampilan yang harus menyesuaikan berbagai ukuran layar.

Tahap 2 : MediaQuery: Membaca Karakteristik Layar

Pada tahap ini saya mencoba menggunakan MediaQuery untuk melihat ukuran dan orientasi layar. Hasilnya, nilai width dan height berubah ketika emulator diputar dari portrait ke landscape. Saya juga mencoba kondisi width < 600 untuk membedakan tampilan Compact dan Wide. Dari sini saya jadi memahami bahwa ukuran layar bisa digunakan sebagai acuan untuk mengatur tampilan aplikasi agar menyesuaikan device.

Tahap 3 : LayoutBuilder dan Breakpoint

Pada tahap ini saya mencoba menggunakan LayoutBuilder untuk menyesuaikan tampilan berdasarkan lebar ruang yang tersedia. Hasilnya, layout dapat berubah dari Compact, Medium, sampai Expanded ketika ukuran window diperbesar. Saya juga melihat bahwa LayoutBuilder berbeda dengan MediaQuery, karena LayoutBuilder lebih fokus pada ruang yang tersedia untuk widget tersebut, bukan hanya ukuran layar secara keseluruhan.

Tahap 4 : Expanded, Flexible, dan Wrap

Pada tahap ini saya mencoba menggunakan Expanded dengan nilai flex yang berbeda. Hasilnya, ruang yang tersedia terbagi sesuai perbandingan flex, sehingga flex: 2 mendapatkan ruang dua kali lebih besar dari flex: 1. Saya juga mencoba Wrap untuk menampilkan beberapa Chip. Saat ukuran layar diperkecil, Chip otomatis berpindah ke baris berikutnya sehingga tidak terjadi overflow. Dari percobaan ini saya memahami bahwa Expanded berguna untuk membagi ruang, sedangkan Wrap cocok digunakan ketika jumlah item bisa bertambah atau ruang yang tersedia terbatas.

Tahap 5 : GridView Responsif

Pada tahap ini saya mencoba membuat tampilan daftar course menggunakan GridView. Jumlah kolom dibuat menyesuaikan lebar layar, sehingga pada layar yang kecil tampil 1 kolom, sedangkan saat window diperbesar menjadi 2 atau 3 kolom. Saya juga menyesuaikan ukuran kartu agar teks tetap nyaman dibaca. Dari percobaan ini saya melihat bahwa penggunaan jumlah kolom yang dinamis membuat tampilan grid lebih fleksibel dan tidak mudah mengalami overflow ketika ukuran layar berubah.