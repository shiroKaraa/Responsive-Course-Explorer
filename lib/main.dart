import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'quiz_data.dart';

// IDENTITAS
const String studentName = 'I Kadek Dwi Bajaskara';
const String studentId = '2415051068';

class AppColors {
  static const primary = Color(0xFF1565C0);
  static const primarySoft = Color(0xFFE3F0FC);
  static const success = Color(0xFF2E7D32);
  static const successSoft = Color(0xFFE6F4EA);
  static const warn = Color(0xFFEF6C00);
  static const muted = Color(0xFF607D8B);
  static const bg = Color(0xFFF5F8FC);
  static const border = Color(0xFFE3E8EF);
}

Future<Map<String, dynamic>> loadStudentData() async {
  final jsonString = await rootBundle.loadString(
    'assets/data/student_data.json',
  );
  return jsonDecode(jsonString) as Map<String, dynamic>;
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  final EdgeInsets margin;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderColor,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor ?? AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

Widget sectionTitle(String text) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
  );
}

Widget buildStatCard({
  required String value,
  required String label,
  required IconData icon,
  required Color color,
}) {
  return Expanded(
    child: AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    ),
  );
}

class StatusHelper {
  static Color color(String s) {
    switch (s) {
      case 'done':
        return AppColors.success;
      case 'active':
        return AppColors.warn;
      default:
        return AppColors.muted;
    }
  }

  static IconData icon(String s) {
    switch (s) {
      case 'done':
        return Icons.check_circle;
      case 'active':
        return Icons.play_circle;
      default:
        return Icons.schedule;
    }
  }

  static String label(String s) {
    switch (s) {
      case 'done':
        return 'Selesai';
      case 'active':
        return 'Berjalan';
      default:
        return 'Belum';
    }
  }

  static Widget badge(String s) {
    final c = color(s);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label(s),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: c,
        ),
      ),
    );
  }
}

class GreetingCard extends StatefulWidget {
  const GreetingCard({super.key});

  @override
  State<GreetingCard> createState() => _GreetingCardState();
}

class _GreetingCardState extends State<GreetingCard> {
  final _controller = TextEditingController();
  String _message = 'Belum ada pesan';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tampilkan() {
    setState(() {
      _message = _controller.text.trim().isEmpty
          ? 'Input masih kosong'
          : _controller.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.chat_bubble_outline,
                  color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                'Latihan Interaksi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('$studentId - $studentName',
              style: const TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Tulis pesan...',
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.edit, size: 20),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _tampilkan,
            icon: const Icon(Icons.send, size: 18),
            label: const Text('Tampilkan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MiniQuizCard extends StatefulWidget {
  const MiniQuizCard({super.key});

  @override
  State<MiniQuizCard> createState() => _MiniQuizCardState();
}

class _MiniQuizCardState extends State<MiniQuizCard> {
  int _index = 0;
  String? _selected;
  int _score = 0;
  bool _finished = false;

  void _pilih(String opsi) {
    if (_selected != null) return;
    setState(() {
      _selected = opsi;
      if (opsi == quizQuestions[_index]['answer']) _score++;
    });
  }

  void _next() {
    setState(() {
      if (_index < quizQuestions.length - 1) {
        _index++;
        _selected = null;
      } else {
        _finished = true;
      }
    });
  }

  void _reset() {
    setState(() {
      _index = 0;
      _selected = null;
      _score = 0;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = quizQuestions.length;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.quiz_outlined,
                  color: AppColors.success, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Mini Quiz Akademik',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              const Spacer(),
              Text(
                _finished ? 'Selesai' : 'Soal ${_index + 1}/$total',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_finished) _buildHasil(total) else _buildSoal(),
        ],
      ),
    );
  }

  Widget _buildSoal() {
    final item = quizQuestions[_index];
    final options = (item['options'] as List).cast<String>();
    final answer = item['answer'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          item['q'] as String,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        ...options.map((opsi) {
          final isSelected = _selected == opsi;
          final isCorrect = opsi == answer;
          final show = _selected != null;

          Color border = AppColors.border;
          Color bg = Colors.white;
          if (show && isCorrect) {
            border = AppColors.success;
            bg = AppColors.successSoft;
          } else if (show && isSelected && !isCorrect) {
            border = Colors.red.shade400;
            bg = const Color(0xFFFFEBEE);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => _pilih(opsi),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    Icon(
                      show && isCorrect
                          ? Icons.check_circle
                          : (show && isSelected
                              ? Icons.cancel
                              : Icons.radio_button_unchecked),
                      size: 18,
                      color: show && isCorrect
                          ? AppColors.success
                          : (show && isSelected
                              ? Colors.red.shade400
                              : AppColors.muted),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(opsi,
                          style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        if (_selected != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _next,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(
                _index < quizQuestions.length - 1
                    ? 'Soal Berikutnya'
                    : 'Lihat Skor',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHasil(int total) {
    final persen = (_score / total * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        Text(
          'Skor kamu: $_score / $total',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 4),
        Text('Nilai: $persen',
            style: const TextStyle(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Ulangi Quiz'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> _studentFuture;

  @override
  void initState() {
    super.initState();
    _studentFuture = loadStudentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Learning Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _studentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Gagal memuat data: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }
            return _buildDashboard(snapshot.data!);
          },
        ),
      ),
    );
  }

  Widget _buildDashboard(Map<String, dynamic> data) {
    final student = data['student'] as Map<String, dynamic>;
    final courses = data['courses'] as List<dynamic>;
    final learningGoal =
        (data['learning_goal'] as String?) ?? 'Belum ada learning goal.';

    final name = (student['name'] as String?) ?? studentName;
    final nim = (student['nim'] as String?) ?? studentId;
    final program = (student['program'] as String?) ?? 'Mahasiswa';
    final semester = student['semester'] ?? '-';

    final total = courses.length;
    final done = courses
        .where((c) => (c as Map<String, dynamic>)['status'] == 'done')
        .length;
    final progress = total == 0 ? 0 : ((done / total) * 100).round();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: _identityCard(name, nim, program, semester),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: 5 + courses.length,
            itemBuilder: (context, i) {
              if (i == 0) return _summaryCards(total, done, progress);
              if (i == 1) return _learningGoal(learningGoal);
              if (i == 2) return const _Spaced(child: GreetingCard());
              if (i == 3) return const _Spaced(child: MiniQuizCard());
              if (i == 4) return _courseHeader(done, total);

              final course = courses[i - 5];
              if (course is! Map<String, dynamic>) {
                return const SizedBox.shrink();
              }
              final status = (course['status'] as String?) ?? 'planned';
              return _courseCard(course, status);
            },
          ),
        ),
      ],
    );
  }

  Widget _identityCard(
      String name, String nim, String program, dynamic semester) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primarySoft,
            child: ClipOval(
              child: Image.asset(
                'assets/images/profile.jpg',
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text('NIM: $nim',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 2),
                Text(
                  '$program • Semester $semester',
                  style: const TextStyle(
                      fontSize: 11, color: Colors.black45),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCards(int total, int done, int progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          buildStatCard(
            value: '$total',
            label: 'Total Topik',
            icon: Icons.book_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          buildStatCard(
            value: '$done',
            label: 'Selesai',
            icon: Icons.check_circle_outline,
            color: AppColors.success,
          ),
          const SizedBox(width: 10),
          buildStatCard(
            value: '$progress%',
            label: 'Progress',
            icon: Icons.trending_up,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _learningGoal(String goal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle('Learning Goal'),
          const SizedBox(height: 8),
          AppCard(
            borderColor: AppColors.success.withValues(alpha: 0.25),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.flag_outlined,
                    color: AppColors.success, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    goal,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _courseHeader(int done, int total) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          sectionTitle('Daftar Materi'),
          Text(
            '$done dari $total selesai',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _courseCard(Map<String, dynamic> course, String status) {
    final color = StatusHelper.color(status);
    final title = (course['title'] as String?) ?? 'Tanpa Judul';
    final code = (course['code'] as String?) ?? '-';
    final credits = course['credits']?.toString() ?? '-';
    final description = (course['description'] as String?) ?? '';
    final dosen = (course['dosen'] as String?) ?? '-';

    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderColor: color.withValues(alpha: 0.20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(StatusHelper.icon(status), color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text('$code • $credits SKS',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54)),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black45,
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Dosen: $dosen',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black45,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusHelper.badge(status),
        ],
      ),
    );
  }
}

class _Spaced extends StatelessWidget {
  final Widget child;
  const _Spaced({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: child,
    );
  }
}

class HardcodedDemoPage extends StatelessWidget {
  const HardcodedDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    final category = size.width < 600 ? 'Compact' : 'Wide';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worksheet Pertemuan 5'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Buka Breakpoint Demo',
            icon: const Icon(Icons.grid_view),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BreakpointDemoPage(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Buka Flex Demo',
            icon: const Icon(Icons.view_column),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FlexDemoPage(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: AppColors.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informasi Layar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 8),

                Text(
                  'Width: ${size.width.toStringAsFixed(0)} px',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  'Height: ${size.height.toStringAsFixed(0)} px',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 6),

                Text(
                  'Orientation: $orientation',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      'Kategori: ',
                      style: TextStyle(fontSize: 14),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: category == 'Compact'
                            ? AppColors.warn.withValues(alpha: 0.15)
                            : AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: category == 'Compact'
                              ? AppColors.warn
                              : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 32),

                Text(
                  studentName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'NIM: $studentId',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Coba putar layar portrait ↔ landscape dan amati '
                  'perubahan width, height, orientation, dan kategori.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black45,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tekan ikon grid di kanan atas untuk membuka halaman '
                  'Breakpoint Demo, dan ikon kolom untuk membuka Flex Demo.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===== WIDGET LAYOUT UNTUK BREAKPOINT DEMO =====

class CompactLayout extends StatelessWidget {
  const CompactLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AppCard(
          padding: const EdgeInsets.all(20),
          borderColor: AppColors.warn.withValues(alpha: 0.4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_android,
                  size: 48, color: AppColors.warn),
              const SizedBox(height: 12),
              const Text(
                'Compact Layout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.warn,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Lebar < 600 px',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const Divider(height: 24),
              Text(
                studentName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'NIM: $studentId',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MediumLayout extends StatelessWidget {
  const MediumLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AppCard(
          padding: const EdgeInsets.all(20),
          borderColor: AppColors.primary.withValues(alpha: 0.4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tablet_android,
                  size: 56, color: AppColors.primary),
              const SizedBox(height: 12),
              const Text(
                'Medium Layout',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Lebar 600 - 839 px',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const Divider(height: 24),
              Text(
                studentName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'NIM: $studentId',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpandedLayout extends StatelessWidget {
  const ExpandedLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AppCard(
          padding: const EdgeInsets.all(24),
          borderColor: AppColors.success.withValues(alpha: 0.4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.desktop_windows,
                  size: 64, color: AppColors.success),
              const SizedBox(height: 12),
              const Text(
                'Expanded Layout',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Lebar ≥ 840 px',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const Divider(height: 24),
              Text(
                studentName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'NIM: $studentId',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BreakpointDemoPage extends StatelessWidget {
  const BreakpointDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worksheet Pertemuan 5'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return const CompactLayout();
          } else if (constraints.maxWidth < 840) {
            return const MediumLayout();
          } else {
            return const ExpandedLayout();
          }
        },
      ),
    );
  }
}

class FlexDemoPage extends StatelessWidget {
  const FlexDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worksheet Pertemuan 5'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Identitas
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NIM: $studentId',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            sectionTitle('A. Expanded dengan Flex 2:1'),
            const SizedBox(height: 4),
            const Text(
              'Dua panel dalam Row dengan flex 2 dan 1. '
              'Panel kiri mendapat 2/3 ruang, panel kanan 1/3.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Panel A (flex: 2)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Panel B\n(flex: 1)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            sectionTitle('B. Wrap dengan Chip Skill'),
            const SizedBox(height: 4),
            const Text(
              'Wrap memindahkan item ke baris berikutnya jika ruang tidak cukup. ',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                Chip(
                  avatar: Icon(Icons.code, size: 16),
                  label: Text('Flutter'),
                ),
                Chip(
                  avatar: Icon(Icons.storage, size: 16),
                  label: Text('Dart'),
                ),
                Chip(
                  avatar: Icon(Icons.cloud, size: 16),
                  label: Text('REST API'),
                ),
                Chip(
                  avatar: Icon(Icons.palette, size: 16),
                  label: Text('UI Design'),
                ),
                Chip(
                  avatar: Icon(Icons.storage_outlined, size: 16),
                  label: Text('Database'),
                ),
                Chip(
                  avatar: Icon(Icons.account_tree, size: 16),
                  label: Text('State Management'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            sectionTitle('C. Perbandingan: Row Biasa (Overflow)'),
            const SizedBox(height: 4),
            const Text(
              'Row di bawah ini berisi banyak item dengan lebar tetap. '
              'Jika layar sempit, akan muncul overflow (garis kuning-hitam).',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warn.withValues(alpha: 0.4)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    _BoxItem('Item 1'),
                    SizedBox(width: 6),
                    _BoxItem('Item 2'),
                    SizedBox(width: 6),
                    _BoxItem('Item 3'),
                    SizedBox(width: 6),
                    _BoxItem('Item 4'),
                    SizedBox(width: 6),
                    _BoxItem('Item 5'),
                    SizedBox(width: 6),
                    _BoxItem('Item 6'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _BoxItem extends StatelessWidget {
  final String label;
  const _BoxItem(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warn.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warn),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learning Dashboard',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
      ),
      home: const FlexDemoPage(),
    );
  }
}

void main() {
  runApp(const MyApp());
}