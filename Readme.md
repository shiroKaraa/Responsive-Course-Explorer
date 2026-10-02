Tahap 0 : Setup

Project Worksheet Pertemuan 5 ini merupakan lanjutan dari project Worksheet Pertemuan 4. Saya menggunakan file main.dart dari pertemuan sebelumnya sebagai dasar, lalu mengembangkannya secara bertahap mengikuti tahapan pada Worksheet 5 (Tahap 1–17) untuk menerapkan konsep responsive layout, navigation, dan user interaction. Struktur project, data JSON, dan identitas mahasiswa (Nama & NIM) tetap dipertahankan.

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

Tahap 6 : Scrollable Content dan Keyboard

Pada tahap ini saya mencoba membuat form profil dengan beberapa TextField. Saat scroll belum digunakan, bagian bawah form tidak terlihat karena tinggi konten melebihi layar dan muncul overflow. Setelah menggunakan SingleChildScrollView, seluruh isi form dapat digeser dan ditampilkan dengan baik. Saya juga menemukan bahwa keyboard dapat menutupi field yang berada di bagian bawah, sehingga perlu menambahkan padding berdasarkan viewInsets.bottom. Dari percobaan ini saya memahami bahwa scroll cukup penting untuk form yang memiliki banyak input, terutama saat digunakan pada layar HP.

Tahap 6.5 (DEBUG) : Refactoring/Penyederhanaan Kode dan Perbaikan Beberapa BUG

Sebelum masuk Tahap 7, saya melakukan refactoring pada main.dart untuk merapikan kode dan memperbaiki beberapa bug: (1) home: diubah dari ProfileFormPage ke HomePage agar menu Tahap 1–6 dapat diakses; (2) childAspectRatio pada GridView diganti mainAxisExtent agar tidak overflow; (3) teks hint di Tahap 4 bagian C disesuaikan. Duplikasi seperti header identitas, AppBar, kartu course, dan layout breakpoint digabung menjadi widget reusable. DashboardPage dan GreetingCard dinonaktifkan sementara karena tidak dipakai di tahap 1–6. Sedangkan MiniQuizCard dan quiz_data.dart sengaja dinonaktifkan sementara dan akan digunakan kembali pada Tahap 15 (Mini Project Integrasi). Hasilnya, file main.dart menyusut dari ~1.800 baris menjadi ~680 baris dengan struktur yang lebih bersih.

Tahap 7 : Navigator.push() dan Navigator.pop()

Pada tahap ini saya mencoba membuat perpindahan halaman dari HomePage ke DetailPage menggunakan Navigator.push(). Setelah masuk ke DetailPage, tombol back pada AppBar otomatis muncul karena halaman tersebut berada di atas HomePage. Saya juga mencoba tombol "Kembali" menggunakan Navigator.pop(), dan hasilnya sama-sama kembali ke halaman sebelumnya. Dari percobaan ini saya lebih memahami bahwa navigasi Flutter bekerja seperti stack, yaitu push untuk menambahkan halaman dan pop untuk kembali atau menghapus halaman teratas.