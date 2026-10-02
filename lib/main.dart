import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// IDENTITAS
const String studentName = 'I Kadek Dwi Bajaskara';
const String studentId = '2415051068';

class AppColors {
  static const primary = Color(0xFF1565C0);
  static const primarySoft = Color(0xFFE3F0FC);
  static const success = Color(0xFF2E7D32);
  static const warn = Color(0xFFEF6C00);
  static const muted = Color(0xFF607D8B);
  static const bg = Color(0xFFF5F8FC);
  static const border = Color(0xFFE3E8EF);
}

Future<Map<String, dynamic>> loadStudentData() async => jsonDecode(
    await rootBundle.loadString('assets/data/student_data.json'))
    as Map<String, dynamic>;

// ===== REUSABLE WIDGET =====

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor ?? AppColors.border),
          boxShadow: const [
            BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: child,
      );
}

Widget sectionTitle(String t) => Text(t,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));

Widget hint(String t) =>
    Text(t, style: const TextStyle(fontSize: 12, color: Colors.black54));

class DemoScaffold extends StatelessWidget {
  final Widget body;
  final List<Widget>? actions;
  const DemoScaffold({super.key, required this.body, this.actions});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: const Text('Worksheet Pertemuan 5'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: actions,
        ),
        body: body,
      );
}

class IdentityCard extends StatelessWidget {
  final String name, nim;
  final String? subtitle;
  const IdentityCard({
    super.key,
    this.name = studentName,
    this.nim = studentId,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) => AppCard(
        child: Row(children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primarySoft,
            child: ClipOval(
              child: Image.asset(
                'assets/images/profile.jpg',
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person, size: 30, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text('NIM: $nim',
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
              if (subtitle != null)
                Text(subtitle!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.black45)),
            ]),
          ),
        ]),
      );
}

class StatusHelper {
  static const _map = {
    'done': (AppColors.success, Icons.check_circle, 'Selesai'),
    'active': (AppColors.warn, Icons.play_circle, 'Berjalan'),
  };
  static (Color, IconData, String) _of(String s) =>
      _map[s] ?? (AppColors.muted, Icons.schedule, 'Belum');

  static Color color(String s) => _of(s).$1;
  static IconData icon(String s) => _of(s).$2;

  static Widget badge(String s) {
    final (c, _, label) = _of(s);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: c)),
    );
  }
}

// ===== HOME (MENU TAHAP + NAVIGASI) =====

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final menu = <(String, String, IconData, Widget)>[
      ('Tahap 1', 'Hard-coded vs Fleksibel', Icons.warning_amber, const HardcodedDemoPage()),
      ('Tahap 2', 'MediaQuery', Icons.straighten, const MediaQueryPage()),
      ('Tahap 3', 'LayoutBuilder & Breakpoint', Icons.devices, const BreakpointDemoPage()),
      ('Tahap 4', 'Expanded, Flexible, Wrap', Icons.view_column, const FlexDemoPage()),
      ('Tahap 5', 'GridView Responsif', Icons.grid_view, const CourseGridPage()),
      ('Tahap 6', 'Scroll & Keyboard (Form)', Icons.person_outline, const ProfileFormPage()),
      ('Tahap 8', 'Course Detail (Passing Data)', Icons.article_outlined, const CourseGridPage()),
    ];

    return DemoScaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const IdentityCard(),
          const SizedBox(height: 16),

          AppCard(
            padding: EdgeInsets.zero,
            borderColor: AppColors.primary.withValues(alpha: 0.4),
            child: ListTile(
              leading: const Icon(Icons.open_in_new, color: AppColors.primary),
              title: const Text(
                'Tahap 7: Buka Detail Page',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Navigator.push() dan Navigator.pop()'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DetailPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          sectionTitle('Menu Tahapan'),
          const SizedBox(height: 8),

          for (final m in menu)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: Icon(m.$3, color: AppColors.primary),
                  title: Text('${m.$1}: ${m.$2}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => m.$4)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ===== TAHAP 7: DETAIL PAGE =====

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const IdentityCard(),

            const SizedBox(height: 16),
            sectionTitle('Detail Page'),
            const SizedBox(height: 8),

            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Halaman ini dibuka dengan Navigator.push()',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  hint(
                    'Anda berada di DetailPage. Halaman ini ditambahkan ke '
                    'navigation stack di atas HomePage.',
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  Text(
                    studentName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Kembali'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            AppCard(
              borderColor: AppColors.success.withValues(alpha: 0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: AppColors.success, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Yang perlu diamati',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  hint(
                    '1. AppBar otomatis memiliki tombol back (←).\n'
                    '2. Tombol "Kembali" memanggil Navigator.pop(context) '
                    'secara eksplisit.\n'
                    '3. Keduanya menghapus DetailPage dari stack.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ===== TAHAP 8: COURSE DETAIL PAGE =====

class CourseDetailPage extends StatelessWidget {
  final Map<String, dynamic> course;
  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final status = (course['status'] as String?) ?? 'planned';
    final color = StatusHelper.color(status);
    final title = (course['title'] as String?) ?? 'Tanpa Judul';
    final code = (course['code'] as String?) ?? '-';
    final credits = course['credits']?.toString() ?? '-';
    final description = (course['description'] as String?) ?? 'Tidak ada deskripsi.';
    final dosen = (course['dosen'] as String?) ?? '-';

    return DemoScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              padding: const EdgeInsets.all(16),
              borderColor: color.withValues(alpha: 0.4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(StatusHelper.icon(status), color: color, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '$code • $credits SKS',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      StatusHelper.badge(status),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            sectionTitle('Deskripsi'),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),

            sectionTitle('Informasi Course'),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _infoRow(Icons.tag, 'Kode', code),
                  const Divider(height: 20),
                  _infoRow(Icons.credit_card, 'SKS', '$credits SKS'),
                  const Divider(height: 20),
                  _infoRow(Icons.person, 'Dosen', dosen),
                  const Divider(height: 20),
                  _infoRow(Icons.info_outline, 'Status',
                      StatusHelper._of(status).$3),
                ],
              ),
            ),
            const SizedBox(height: 16),

            sectionTitle('Identitas Mahasiswa'),
            const SizedBox(height: 8),
            const IdentityCard(),

            const SizedBox(height: 16),
            AppCard(
              borderColor: AppColors.primary.withValues(alpha: 0.3),
              child: hint(
                'Halaman ini menerima data course melalui constructor: '
                'CourseDetailPage(course: courses[index]). '
                'Semua informasi di atas berasal dari Map course tersebut.',
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

// ===== TAHAP 1: HARD-CODED vs FLEKSIBEL =====

class HardcodedDemoPage extends StatefulWidget {
  const HardcodedDemoPage({super.key});

  @override
  State<HardcodedDemoPage> createState() => _HardcodedDemoPageState();
}

class _HardcodedDemoPageState extends State<HardcodedDemoPage> {
  bool _fixed = true;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: _fixed ? 500 : double.infinity,
      padding: const EdgeInsets.all(16),
      color: _fixed ? AppColors.warn.withValues(alpha: 0.2) : AppColors.primarySoft,
      child: const Text('$studentId - $studentName'),
    );

    return DemoScaffold(
      actions: [
        Text(_fixed ? 'width: 500' : 'double.infinity',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        Switch(
          value: _fixed,
          activeThumbColor: Colors.white,
          activeTrackColor: AppColors.warn,
          onChanged: (v) => setState(() => _fixed = v),
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          hint(_fixed
              ? 'Width tetap 500: overflow di layar kecil (garis kuning-hitam).'
              : 'double.infinity: mengikuti ruang yang tersedia.'),
          const SizedBox(height: 12),
          Row(children: [_fixed ? box : Expanded(child: box)]),
        ]),
      ),
    );
  }
}

// ===== TAHAP 2: MEDIAQUERY =====

class MediaQueryPage extends StatelessWidget {
  const MediaQueryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final compact = size.width < 600;
    final c = compact ? AppColors.warn : AppColors.success;

    return DemoScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Informasi Layar',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const Divider(),
                Text('Width: ${size.width.toStringAsFixed(0)} px'),
                const SizedBox(height: 6),
                Text('Height: ${size.height.toStringAsFixed(0)} px'),
                const SizedBox(height: 6),
                Text('Orientation: $orientation'),
                const SizedBox(height: 6),
                Row(children: [
                  const Text('Kategori: '),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(compact ? 'Compact' : 'Wide',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold, color: c)),
                  ),
                ]),
                const Divider(height: 32),
                const Text(studentName,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('NIM: $studentId',
                    style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===== TAHAP 3: LAYOUTBUILDER & BREAKPOINT =====

class _LayoutCard extends StatelessWidget {
  final String title, range;
  final IconData icon;
  final Color color;
  final double scale;
  const _LayoutCard(this.title, this.range, this.icon, this.color, this.scale);

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppCard(
            padding: EdgeInsets.all(16 + scale * 4),
            borderColor: color.withValues(alpha: 0.4),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 40 + scale * 8, color: color),
              const SizedBox(height: 12),
              Text(title,
                  style: TextStyle(
                      fontSize: 16 + scale * 2,
                      fontWeight: FontWeight.bold,
                      color: color)),
              const SizedBox(height: 4),
              hint(range),
              const Divider(height: 24),
              Text(studentName,
                  style: TextStyle(fontSize: 13 + scale * 2, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('NIM: $studentId',
                  style: TextStyle(fontSize: 12 + scale * 1.5, color: Colors.black54)),
            ]),
          ),
        ),
      );
}

class CompactLayout extends StatelessWidget {
  const CompactLayout({super.key});
  @override
  Widget build(BuildContext context) => const _LayoutCard(
      'Compact Layout', 'Lebar < 600 px', Icons.phone_android, AppColors.warn, 0);
}

class MediumLayout extends StatelessWidget {
  const MediumLayout({super.key});
  @override
  Widget build(BuildContext context) => const _LayoutCard(
      'Medium Layout', 'Lebar 600 - 839 px', Icons.tablet_android, AppColors.primary, 1);
}

class ExpandedLayout extends StatelessWidget {
  const ExpandedLayout({super.key});
  @override
  Widget build(BuildContext context) => const _LayoutCard(
      'Expanded Layout', 'Lebar ≥ 840 px', Icons.desktop_windows, AppColors.success, 2);
}

class BreakpointDemoPage extends StatelessWidget {
  const BreakpointDemoPage({super.key});

  @override
  Widget build(BuildContext context) => DemoScaffold(
        body: LayoutBuilder(builder: (context, c) {
          if (c.maxWidth < 600) return const CompactLayout();
          if (c.maxWidth < 840) return const MediumLayout();
          return const ExpandedLayout();
        }),
      );
}

// ===== TAHAP 4: EXPANDED, FLEXIBLE, WRAP =====

class FlexDemoPage extends StatelessWidget {
  const FlexDemoPage({super.key});

  Widget _panel(String text, Color color) => Container(
        height: 100,
        alignment: Alignment.center,
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );

  @override
  Widget build(BuildContext context) {
    const skills = [
      (Icons.code, 'Flutter'),
      (Icons.storage, 'Dart'),
      (Icons.cloud, 'REST API'),
      (Icons.palette, 'UI Design'),
      (Icons.storage_outlined, 'Database'),
      (Icons.account_tree, 'State Management'),
    ];

    return DemoScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const IdentityCard(),
          const SizedBox(height: 16),
          sectionTitle('A. Expanded dengan Flex 2:1'),
          const SizedBox(height: 4),
          hint('Panel kiri mendapat 2/3 ruang, panel kanan 1/3.'),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(flex: 2, child: _panel('Panel A (flex: 2)', AppColors.primary)),
            const SizedBox(width: 8),
            Expanded(child: _panel('Panel B\n(flex: 1)', AppColors.success)),
          ]),
          const SizedBox(height: 24),
          sectionTitle('B. Wrap dengan Chip Skill'),
          const SizedBox(height: 4),
          hint('Wrap memindahkan item ke baris berikutnya jika ruang tidak cukup.'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in skills)
                Chip(avatar: Icon(s.$1, size: 16), label: Text(s.$2)),
            ],
          ),
          const SizedBox(height: 24),
          sectionTitle('C. Perbandingan: Row Biasa'),
          const SizedBox(height: 4),
          hint('Row berisi item lebar tetap, dibungkus scroll horizontal agar tidak overflow.'),
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
              child: Row(children: [
                for (var i = 1; i <= 6; i++)
                  Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.warn.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warn),
                    ),
                    child: Text('Item $i',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// ===== TAHAP 5: GRIDVIEW RESPONSIF =====

int columnsFor(double width) => width < 600 ? 1 : (width < 840 ? 2 : 3);

class CourseGridPage extends StatefulWidget {
  const CourseGridPage({super.key});

  @override
  State<CourseGridPage> createState() => _CourseGridPageState();
}

class _CourseGridPageState extends State<CourseGridPage> {
  late final Future<Map<String, dynamic>> _future = loadStudentData();

  @override
  Widget build(BuildContext context) => DemoScaffold(
        body: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Text('Gagal memuat data: ${snap.error}',
                    style: const TextStyle(color: Colors.red)),
              );
            }
            final data = snap.data!;
            final s = data['student'] as Map<String, dynamic>;
            final courses = (data['courses'] as List).cast<Map<String, dynamic>>();

            return LayoutBuilder(
              builder: (context, c) => Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: IdentityCard(
                    name: s['name'] ?? studentName,
                    nim: s['nim'] ?? studentId,
                    subtitle: '${s['program'] ?? 'Mahasiswa'} • Semester ${s['semester'] ?? '-'}',
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnsFor(c.maxWidth),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 170,
                    ),
                    itemCount: courses.length,
                    itemBuilder: (_, i) => _TappableCourseCard(course: courses[i]),
                  ),
                ),
              ]),
            );
          },
        ),
      );
}

class _TappableCourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  const _TappableCourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseDetailPage(course: course),
          ),
        );
      },
      child: CourseCard(course: course),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final status = (course['status'] as String?) ?? 'planned';
    final color = StatusHelper.color(status);
    final desc = (course['description'] as String?) ?? '';

    return AppCard(
      padding: const EdgeInsets.all(12),
      borderColor: color.withValues(alpha: 0.25),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(StatusHelper.icon(status), color: color, size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: Text(course['title'] ?? 'Tanpa Judul',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ]),
        const SizedBox(height: 4),
        Text('${course['code'] ?? '-'} • ${course['credits'] ?? '-'} SKS',
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 4),
        Expanded(
          child: Text(desc,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.black45, height: 1.3)),
        ),
        Row(children: [
          Expanded(
            child: Text('Dosen: ${course['dosen'] ?? '-'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 10, color: Colors.black45, fontStyle: FontStyle.italic)),
          ),
          StatusHelper.badge(status),
        ]),
      ]),
    );
  }
}

// ===== TAHAP 6: SCROLLABLE CONTENT & KEYBOARD =====

class ProfileFormPage extends StatefulWidget {
  const ProfileFormPage({super.key});

  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  bool _useScroll = true;

  static const _fields = <(String, String, IconData, TextInputType, int)>[
    ('Nama Lengkap', studentName, Icons.person_outline, TextInputType.text, 1),
    ('NIM', studentId, Icons.badge_outlined, TextInputType.number, 1),
    ('Email', 'bajaskara@example.com', Icons.email_outlined, TextInputType.emailAddress, 1),
    ('Program Studi', 'Pendidikan Teknik Informatika', Icons.school_outlined, TextInputType.text, 1),
    ('Semester', '5', Icons.calendar_today_outlined, TextInputType.number, 1),
    ('Bio', 'Mahasiswa PTI yang sedang belajar Flutter untuk pengembangan aplikasi mobile.',
        Icons.description_outlined, TextInputType.multiline, 3),
  ];

  late final _controllers = [
    for (final f in _fields) TextEditingController(text: f.$2),
  ];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const IdentityCard(),
      const SizedBox(height: 16),
      sectionTitle('Form Profil Mahasiswa'),
      const SizedBox(height: 8),
      AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          for (var i = 0; i < _fields.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == _fields.length - 1 ? 0 : 12),
              child: TextField(
                controller: _controllers[i],
                keyboardType: _fields[i].$4,
                maxLines: _fields[i].$5,
                decoration: InputDecoration(
                  labelText: _fields[i].$1,
                  isDense: true,
                  prefixIcon: Icon(_fields[i].$3, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 16),
      AppCard(
        borderColor: AppColors.primary.withValues(alpha: 0.3),
        child: hint('Eksperimen: matikan switch "Scroll" di AppBar untuk melihat overflow, '
            'lalu ketuk field Bio untuk membuka keyboard dan amati apakah halaman '
            'masih bisa di-scroll.'),
      ),
      const SizedBox(height: 24),
    ]);

    return DemoScaffold(
      actions: [
        Text(_useScroll ? 'Scroll ON' : 'Scroll OFF',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        Switch(
          value: _useScroll,
          activeThumbColor: Colors.white,
          activeTrackColor: AppColors.success,
          onChanged: (v) => setState(() => _useScroll = v),
        ),
      ],
      body: _useScroll
          ? SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  16, 12, 16, 24 + MediaQuery.of(context).viewInsets.bottom),
              child: content,
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: content,
            ),
    );
  }
}

// ===== APP =====

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Worksheet Pertemuan 5',
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.bg,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        ),
        home: const HomePage(),
      );
}

void main() => runApp(const MyApp());