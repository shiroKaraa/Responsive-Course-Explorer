// ===== DATA MINI QUIZ (dipisah dari widget) =====

const List<Map<String, dynamic>> quizQuestions = [
  {
    'q': 'Apa bahasa pemrograman yang digunakan Flutter?',
    'options': ['Java', 'Dart', 'Python'],
    'answer': 'Dart',
  },
  {
    'q': 'Widget dasar untuk menampilkan teks di Flutter?',
    'options': ['Text', 'Label', 'Span'],
    'answer': 'Text',
  },
  {
    'q': 'Widget untuk membaca asset lokal seperti JSON?',
    'options': ['rootBundle', 'fileSystem', 'http'],
    'answer': 'rootBundle',
  },
  {
    'q': 'Widget yang membangun UI dari Future?',
    'options': ['FutureBuilder', 'StreamReader', 'AsyncWidget'],
    'answer': 'FutureBuilder',
  },
  {
    'q': 'Method untuk menginisialisasi Future di StatefulWidget?',
    'options': ['initState()', 'build()', 'dispose()'],
    'answer': 'initState()',
  },
  {
    'q': 'Widget yang digunakan untuk membuat daftar yang dapat di-scroll?',
    'options': ['ListView', 'TextView', 'ColumnView'],
    'answer': 'ListView',
  },
  {
    'q': 'Widget yang digunakan untuk membuat tata letak secara vertikal?',
    'options': ['Row', 'Column', 'Stack'],
    'answer': 'Column',
  },
  {
    'q': 'Widget yang digunakan untuk menyusun beberapa widget secara horizontal?',
    'options': ['Row', 'Column', 'Stack'],
    'answer': 'Row',
  },
  {
    'q': 'Widget utama yang biasanya digunakan sebagai struktur dasar sebuah halaman Flutter?',
    'options': ['Scaffold', 'Container', 'MaterialApp'],
    'answer': 'Scaffold',
  },
  {
    'q': 'Widget yang digunakan untuk menampilkan gambar dari asset?',
    'options': ['Image.asset', 'Picture.local', 'AssetImageView'],
    'answer': 'Image.asset',
  },
  {
    'q': 'File yang biasanya digunakan untuk mendeklarasikan asset pada project Flutter?',
    'options': ['pubspec.yaml', 'asset.yaml', 'flutter.json'],
    'answer': 'pubspec.yaml',
  },
  {
    'q': 'Tipe data Dart yang digunakan untuk menyimpan teks?',
    'options': ['String', 'Text', 'Char'],
    'answer': 'String',
  },
  {
    'q': 'Tipe data Dart yang digunakan untuk menyimpan bilangan bulat?',
    'options': ['Double', 'int', 'IntegerValue'],
    'answer': 'int',
  },
  {
    'q': 'Tipe data Dart yang digunakan untuk nilai benar atau salah?',
    'options': ['Boolean', 'bool', 'Check'],
    'answer': 'bool',
  },
  {
    'q': 'Keyword Dart untuk membuat variabel yang nilainya tidak dapat diubah?',
    'options': ['final', 'fixed', 'constant'],
    'answer': 'final',
  },
  {
    'q': 'Keyword Dart untuk membuat nilai compile-time constant?',
    'options': ['static', 'const', 'constant'],
    'answer': 'const',
  },
  {
    'q': 'Widget Flutter yang dapat menyimpan dan mengubah state disebut?',
    'options': ['StatefulWidget', 'StaticWidget', 'DataWidget'],
    'answer': 'StatefulWidget',
  },
  {
    'q': 'Widget Flutter yang tidak memiliki state yang dapat berubah disebut?',
    'options': ['StateWidget', 'StatelessWidget', 'ImmutableState'],
    'answer': 'StatelessWidget',
  },
  {
    'q': 'Method yang digunakan untuk membangun tampilan widget di Flutter?',
    'options': ['render()', 'build()', 'createUI()'],
    'answer': 'build()',
  },
  {
    'q': 'Format data yang digunakan pada student_data.json?',
    'options': ['XML', 'JSON', 'CSV'],
    'answer': 'JSON',
  },
];