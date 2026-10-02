import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, Clipboard, ClipboardData;
import 'quiz_data.dart';

// ===== IDENTITAS =====
const String studentName = 'I Kadek Dwi Bajaskara';
const String studentId = '2415051068';
const String appTitle = 'Responsive Course Explorer';

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

// ===== DATA & STATE BERSAMA =====

final Future<Map<String, dynamic>> studentDataFuture = rootBundle
    .loadString('assets/data/student_data.json')
    .then((s) => jsonDecode(s) as Map<String, dynamic>);

final ValueNotifier<Set<String>> favorites = ValueNotifier(<String>{});
final ValueNotifier<int?> quizScore = ValueNotifier<int?>(null);
final ValueNotifier<String> courseFilter = ValueNotifier<String>('all');

// ===== HELPER =====

void go(BuildContext c, Widget page) =>
    Navigator.push(c, MaterialPageRoute(builder: (_) => page));

void showMsg(BuildContext c, String msg,
    {Color color = AppColors.primary, SnackBarAction? action}) {
  final m = ScaffoldMessenger.of(c);
  m.clearSnackBars();
  m.showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: color,
    duration: const Duration(seconds: 2),
    behavior: SnackBarBehavior.floating,
    action: action,
  ));
}

ButtonStyle filled(Color bg, {double pad = 14}) => ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: pad),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

ButtonStyle outlined(Color c, {double pad = 14}) => OutlinedButton.styleFrom(
      foregroundColor: c,
      side: BorderSide(color: c),
      padding: EdgeInsets.symmetric(vertical: pad),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

Widget sectionTitle(String t) =>
    Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));

Widget hint(String t) =>
    Text(t, style: const TextStyle(fontSize: 12, color: Colors.black54));

// ===== REUSABLE WIDGET =====

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  final VoidCallback? onTap, onLongPress;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderColor,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(14);
    Widget inner = Padding(padding: padding, child: child);
    if (onTap != null || onLongPress != null) {
      inner = InkWell(
          borderRadius: r, onTap: onTap, onLongPress: onLongPress, child: inner);
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: r,
        border: Border.all(color: borderColor ?? AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Material(type: MaterialType.transparency, child: inner),
    );
  }
}

class DemoScaffold extends StatelessWidget {
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  const DemoScaffold(
      {super.key, required this.body, this.actions, this.bottomNavigationBar});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: const Text(appTitle),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: actions,
        ),
        body: body,
        bottomNavigationBar: bottomNavigationBar,
      );
}

class ScrollPage extends StatelessWidget {
  final List<Widget> children;
  const ScrollPage(this.children, {super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, 24 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      );
}

class IdentityCard extends StatelessWidget {
  final String name, nim;
  final String? subtitle;
  const IdentityCard(
      {super.key, this.name = studentName, this.nim = studentId, this.subtitle});

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
  static String label(String s) => _of(s).$3;

  static double progressOf(String s) {
    if (s == 'done') return 1.0;
    if (s == 'active') return 0.5;
    return 0.0;
  }

  static Widget badge(String s) {
    final c = color(s);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label(s),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: c)),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const InfoRow(this.icon, this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        const Spacer(),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        ),
      ]);
}

class RuleRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, desc;
  const RuleRow(this.icon, this.color, this.title, this.desc, {super.key});

  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(desc,
                style: const TextStyle(
                    fontSize: 12, color: Colors.black54, height: 1.4)),
          ]),
        ),
      ]);
}

Widget ruleCard(List<RuleRow> rows) => AppCard(
      child: Column(children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const Divider(height: 20),
          rows[i],
        ],
      ]),
    );

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
        quizScore.value = _score;
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
    if (total == 0) {
      return AppCard(
        borderColor: AppColors.primary.withValues(alpha: 0.3),
        child: hint('Belum ada soal pada quiz_data.dart.'),
      );
    }
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.primary.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.quiz_outlined,
                  color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Mini Quiz',
                style: TextStyle(
                  fontSize: 15,
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
          style: filled(AppColors.success),
        ),
      ],
    );
  }
}

class FavoriteSectionCard extends StatelessWidget {
  const FavoriteSectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: favorites,
      builder: (context, favs, _) {
        return FutureBuilder<Map<String, dynamic>>(
          future: studentDataFuture,
          builder: (context, snap) {
            final courses = ((snap.data?['courses'] as List?) ?? [])
                .cast<Map<String, dynamic>>();
            final favCourses = courses
                .where((c) => favs.contains(c['code']?.toString() ?? ''))
                .toList();

            return AppCard(
              padding: const EdgeInsets.all(14),
              borderColor: AppColors.success.withValues(alpha: 0.35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Course Favorite',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${favCourses.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (favCourses.isEmpty)
                    hint('Belum ada course favorite. '
                        'Tap ikon ⭐ di halaman detail course.')
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final c in favCourses)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () =>
                                  go(context, CourseDetailPage(course: c, isFavorite: true)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.bookmark,
                                        size: 16, color: AppColors.success),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        c['title']?.toString() ?? 'Tanpa Judul',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right,
                                        size: 18, color: AppColors.muted),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;

  static const _pages = <Widget>[
    _HomeTabPage(),
    CourseGridPage(),
    _ProfileTabPage(),
  ];

  static const _dest = <(IconData, IconData, String)>[
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.school_outlined, Icons.school, 'Courses'),
    (Icons.person_outline, Icons.person, 'Profile'),
  ];

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 840;
        return DemoScaffold(
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: _select,
                  backgroundColor: Colors.white,
                  indicatorColor: AppColors.primarySoft,
                  destinations: [
                    for (final d in _dest)
                      NavigationDestination(
                        icon: Icon(d.$1),
                        selectedIcon: Icon(d.$2, color: AppColors.primary),
                        label: d.$3,
                      ),
                  ],
                ),
          body: Row(children: [
            if (wide) ...[
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: _select,
                backgroundColor: Colors.white,
                indicatorColor: AppColors.primarySoft,
                labelType: NavigationRailLabelType.all,
                destinations: [
                  for (final d in _dest)
                    NavigationRailDestination(
                      icon: Icon(d.$1),
                      selectedIcon: Icon(d.$2, color: AppColors.primary),
                      label: Text(d.$3),
                    ),
                ],
              ),
              const VerticalDivider(width: 1, thickness: 1),
            ],
            Expanded(
              key: const ValueKey('content'),
              child: IndexedStack(index: _index, children: _pages),
            ),
          ]),
        );
      });
}

class _HomeTabPage extends StatelessWidget {
  const _HomeTabPage();

  @override
  Widget build(BuildContext context) {
    final menu = <(String, String, IconData, Widget)>[
      ('Tahap 1', 'Hard-coded vs Fleksibel', Icons.warning_amber, const HardcodedDemoPage()),
      ('Tahap 2', 'MediaQuery', Icons.straighten, const MediaQueryPage()),
      ('Tahap 3', 'LayoutBuilder & Breakpoint', Icons.devices, const BreakpointDemoPage()),
      ('Tahap 4', 'Expanded, Flexible, Wrap', Icons.view_column, const FlexDemoPage()),
      ('Tahap 5, 8 & 9', 'Grid, Detail & Favorite', Icons.grid_view, const CourseGridPage(standalone: true)),
      ('Tahap 6', 'Scroll & Keyboard (Form)', Icons.person_outline, const ProfileFormPage()),
      ('Tahap 7', 'Navigator.push() & pop()', Icons.open_in_new, const DetailPage()),
      ('Tahap 12', 'Interaction Demo', Icons.touch_app, const InteractionDemoPage()),
      ('Tahap 13', 'Form & Validation', Icons.edit_note, const FeedbackFormPage()),
      ('Tahap 14', 'Feedback Demo', Icons.notifications_active, const FeedbackDemoPage()),
      ('Tahap 16', 'Debugging Challenge', Icons.bug_report, const DebugChallengePage()),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const IdentityCard(),
        const SizedBox(height: 16),
        const MiniQuizCard(),
        const SizedBox(height: 12),
        const FavoriteSectionCard(),
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
                onTap: () => go(context, m.$4),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatTile(this.icon, this.label, this.value,
      {this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) => Expanded(
        child: AppCard(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ]),
        ),
      );
}

class _ProfileTabPage extends StatelessWidget {
  const _ProfileTabPage();

  @override
  Widget build(BuildContext context) => ScrollPage([
        const IdentityCard(subtitle: 'Pendidikan Teknik Informatika • Semester 5'),
        const SizedBox(height: 16),
        ValueListenableBuilder<Set<String>>(
          valueListenable: favorites,
          builder: (_, favs, __) => Row(children: [
            const _StatTile(Icons.book_outlined, 'Topik', '5'),
            const SizedBox(width: 10),
            _StatTile(Icons.star_outline, 'Favorite', '${favs.length}',
                color: AppColors.success),
            const SizedBox(width: 10),
            ValueListenableBuilder<int?>(
              valueListenable: quizScore,
              builder: (_, s, __) => _StatTile(
                  Icons.emoji_events_outlined,
                  'Quiz',
                  s == null ? '-' : '$s',
                  color: AppColors.warn),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        sectionTitle('Informasi Mahasiswa'),
        const SizedBox(height: 8),
        const AppCard(
          padding: EdgeInsets.all(16),
          child: Column(children: [
            InfoRow(Icons.person_outline, 'Nama', studentName),
            Divider(height: 20),
            InfoRow(Icons.badge_outlined, 'NIM', studentId),
            Divider(height: 20),
            InfoRow(Icons.school_outlined, 'Program Studi',
                'Pendidikan Teknik Informatika'),
            Divider(height: 20),
            InfoRow(Icons.calendar_today_outlined, 'Semester', '5'),
          ]),
        ),
        const SizedBox(height: 16),

        sectionTitle('About Me'),
        const SizedBox(height: 8),
        AppCard(
          child: hint(
            'Mahasiswa Pendidikan Teknik Informatika yang antusias belajar '
            'Flutter dan pengembangan aplikasi mobile. Senang membangun UI '
            'yang rapi, responsif, dan ramah pengguna.',
          ),
        ),
        const SizedBox(height: 16),

        sectionTitle('About Application'),
        const SizedBox(height: 8),
        AppCard(
          borderColor: AppColors.primary.withValues(alpha: 0.3),
          child: hint(
            'Responsive Course Explorer — dibuat untuk memenuhi Worksheet '
            'Pertemuan 5: Responsive Layout, Navigation & User Interaction. '
            'Dibangun dengan Flutter, tanpa package tambahan, dengan '
            'mempertahankan kesinambungan project dari Pertemuan 4.',
          ),
        ),
        const SizedBox(height: 16),

        sectionTitle('Daftar Favorite'),
        const SizedBox(height: 8),
        const FavoriteSectionCard(),
      ]);
}

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

class MediaQueryPage extends StatelessWidget {
  const MediaQueryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final orientation = MediaQuery.orientationOf(context);
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
                Text('Orientation: ${orientation.name}'),
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
                const Text(studentName, style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('NIM: $studentId', style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
                      fontSize: 16 + scale * 2, fontWeight: FontWeight.bold, color: color)),
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

class FlexDemoPage extends StatelessWidget {
  const FlexDemoPage({super.key});

  Widget _panel(String text, Color color) => Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
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
      body: ScrollPage([
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
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final s in skills) Chip(avatar: Icon(s.$1, size: 16), label: Text(s.$2)),
        ]),
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
    );
  }
}

int columnsFor(double width) => width < 600 ? 1 : (width < 840 ? 2 : 3);

Future<void> openCourse(BuildContext context, Map<String, dynamic> course) async {
  final code = course['code']?.toString() ?? '';
  final wasFav = favorites.value.contains(code);
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => CourseDetailPage(course: course, isFavorite: wasFav),
    ),
  );
  if (result == null || !context.mounted) return;
  favorites.value = result
      ? {...favorites.value, code}
      : ({...favorites.value}..remove(code));
  showMsg(
    context,
    '${course['title'] ?? 'Course'} ${result ? 'ditandai sebagai favorite!' : 'dihapus dari favorite.'}',
    color: result ? AppColors.success : AppColors.primary,
  );
}

Future<void> _confirmRemoveFavorite(
    BuildContext context, Map<String, dynamic> course) async {
  final code = course['code']?.toString() ?? '';
  if (!favorites.value.contains(code)) return;

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Hapus Favorite?'),
      content: Text(
          'Hapus "${course['title'] ?? 'Course'}" dari daftar favorite?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, foregroundColor: Colors.white),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;

  favorites.value = {...favorites.value}..remove(code);
  showMsg(context, 'Dihapus dari favorite.', color: Colors.red);
}

class _FilterChipData {
  final String key, label;
  final IconData icon;
  const _FilterChipData(this.key, this.label, this.icon);
}

const _filterOptions = <_FilterChipData>[
  _FilterChipData('all', 'Semua', Icons.apps),
  _FilterChipData('done', 'Selesai', Icons.check_circle),
  _FilterChipData('active', 'Berjalan', Icons.play_circle),
  _FilterChipData('planned', 'Belum', Icons.schedule),
  _FilterChipData('favorite', 'Favorite', Icons.star),
];

class CourseGridPage extends StatelessWidget {
  final bool standalone;
  const CourseGridPage({super.key, this.standalone = false});

  @override
  Widget build(BuildContext context) {
    final content = FutureBuilder<Map<String, dynamic>>(
      future: studentDataFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || snap.data == null) {
          return Center(
            child: Text('Gagal memuat data: ${snap.error}',
                style: const TextStyle(color: Colors.red)),
          );
        }
        final data = snap.data!;
        final s = (data['student'] as Map<String, dynamic>?) ?? {};
        final courses = ((data['courses'] as List?) ?? [])
            .cast<Map<String, dynamic>>();

        return Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: IdentityCard(
              name: s['name'] ?? studentName,
              nim: s['nim'] ?? studentId,
              subtitle:
                  '${s['program'] ?? 'Mahasiswa'} • Semester ${s['semester'] ?? '-'}',
            ),
          ),
          _FilterBar(favorites: favorites, filter: courseFilter),
          Expanded(
            child: ValueListenableBuilder<Set<String>>(
              valueListenable: favorites,
              builder: (_, favs, __) =>
                  ValueListenableBuilder<String>(
                valueListenable: courseFilter,
                builder: (_, filter, __) {
                  final filtered = courses.where((c) {
                    final code = c['code']?.toString() ?? '';
                    final st = c['status']?.toString() ?? 'planned';
                    switch (filter) {
                      case 'done':
                        return st == 'done';
                      case 'active':
                        return st == 'active';
                      case 'planned':
                        return st == 'planned';
                      case 'favorite':
                        return favs.contains(code);
                      default:
                        return true;
                    }
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.filter_alt_off,
                                size: 48, color: AppColors.muted),
                            const SizedBox(height: 10),
                            hint('Tidak ada course dengan filter ini.'),
                          ],
                        ),
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, c) => GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columnsFor(c.maxWidth),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 170,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final course = filtered[i];
                        final code = course['code']?.toString() ?? '';
                        final isFav = favs.contains(code);
                        return CourseCard(
                          course: course,
                          isFavorite: isFav,
                          onTap: () => openCourse(context, course),
                          onLongPress: () =>
                              _confirmRemoveFavorite(context, course),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ]);
      },
    );

    return standalone ? DemoScaffold(body: content) : content;
  }
}

class _FilterBar extends StatelessWidget {
  final ValueNotifier<Set<String>> favorites;
  final ValueNotifier<String> filter;
  const _FilterBar({required this.favorites, required this.filter});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: filter,
      builder: (_, active, __) => SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemCount: _filterOptions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final opt = _filterOptions[i];
            final selected = active == opt.key;
            return ChoiceChip(
              selected: selected,
              onSelected: (_) => filter.value = opt.key,
              avatar: Icon(
                opt.icon,
                size: 16,
                color: selected ? Colors.white : AppColors.primary,
              ),
              label: Text(opt.label),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.black87,
              ),
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected
                    ? AppColors.primary
                    : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            );
          },
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  const CourseCard({
    super.key,
    required this.course,
    this.isFavorite = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final status = course['status']?.toString() ?? 'planned';
    final color = StatusHelper.color(status);

    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      onLongPress: onLongPress,
      borderColor: isFavorite
          ? AppColors.success.withValues(alpha: 0.6)
          : color.withValues(alpha: 0.25),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(StatusHelper.icon(status), color: color, size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: Text(course['title']?.toString() ?? 'Tanpa Judul',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          if (isFavorite)
            const Icon(Icons.star, color: AppColors.success, size: 18),
        ]),
        const SizedBox(height: 4),
        Text('${course['code'] ?? '-'} • ${course['credits'] ?? '-'} SKS',
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 4),
        Expanded(
          child: Text(course['description']?.toString() ?? '',
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

class CourseDetailPage extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isFavorite;
  const CourseDetailPage({
    super.key,
    required this.course,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    String f(String k, [String d = '-']) => course[k]?.toString() ?? d;
    final status = f('status', 'planned');
    final color = StatusHelper.color(status);
    final credits = f('credits');
    final progress = StatusHelper.progressOf(status);
    final code = f('code');

    return DemoScaffold(
      body: ScrollPage([
        AppCard(
          padding: const EdgeInsets.all(16),
          borderColor: color.withValues(alpha: 0.4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(StatusHelper.icon(status), color: color, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(f('title', 'Tanpa Judul'),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Text('$code • $credits SKS',
                  style: const TextStyle(fontSize: 13, color: Colors.black54)),
              const Spacer(),
              StatusHelper.badge(status),
            ]),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.trending_up, size: 14, color: AppColors.success),
              const SizedBox(width: 6),
              Text('Progress: ${(progress * 100).round()}%',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.success,
                      fontWeight: FontWeight.w600)),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        sectionTitle('Deskripsi'),
        const SizedBox(height: 8),
        AppCard(
          child: Text(f('description', 'Tidak ada deskripsi.'),
              style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.black87)),
        ),
        const SizedBox(height: 16),
        sectionTitle('Informasi Course'),
        const SizedBox(height: 8),
        AppCard(
          child: Column(children: [
            InfoRow(Icons.tag, 'Kode', code),
            const Divider(height: 20),
            InfoRow(Icons.credit_card, 'SKS', '$credits SKS'),
            const Divider(height: 20),
            InfoRow(Icons.person, 'Dosen', f('dosen')),
            const Divider(height: 20),
            InfoRow(Icons.info_outline, 'Status', StatusHelper.label(status)),
          ]),
        ),
        const SizedBox(height: 16),
        sectionTitle('Identitas Mahasiswa'),
        const SizedBox(height: 8),
        const IdentityCard(),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: code));
            if (!context.mounted) return;
            showMsg(context, 'Kode course "$code" disalin.',
                color: AppColors.primary);
          },
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Salin Kode Course'),
          style: outlined(AppColors.primary),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, !isFavorite),
          icon: Icon(isFavorite ? Icons.star_border : Icons.star, size: 18),
          label: Text(isFavorite
              ? 'Hapus dari Favorite & Kembali'
              : 'Tandai Favorite & Kembali'),
          style: filled(isFavorite ? AppColors.muted : AppColors.success),
        ),
        const SizedBox(height: 12),
        AppCard(
          borderColor: AppColors.primary.withValues(alpha: 0.3),
          child: hint(
              'Menekan tombol di atas memanggil Navigator.pop(context, ${!isFavorite}). '
              'Tombol back biasa mengembalikan null (tidak ada perubahan).'),
        ),
      ]),
    );
  }
}

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

  late final _controllers = [for (final f in _fields) TextEditingController(text: f.$2)];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
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
    ];

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
          ? ScrollPage(children)
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
            ),
    );
  }
}

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) => DemoScaffold(
        body: ScrollPage([
          const IdentityCard(),
          const SizedBox(height: 16),
          sectionTitle('Detail Page'),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Halaman ini dibuka dengan Navigator.push()',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.primary)),
                ),
              ]),
              const SizedBox(height: 12),
              hint('Anda berada di DetailPage. Halaman ini ditambahkan ke '
                  'navigation stack di atas MainShellPage.'),
              const Divider(height: 32),
              const Text(studentName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              const Text('NIM: $studentId',
                  style: TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Kembali'),
                style: filled(AppColors.primary, pad: 12),
              ),
            ]),
          ),
        ]),
      );
}

class InteractionDemoPage extends StatefulWidget {
  const InteractionDemoPage({super.key});

  @override
  State<InteractionDemoPage> createState() => _InteractionDemoPageState();
}

class _InteractionDemoPageState extends State<InteractionDemoPage> {
  bool _favorite = false;
  int _tap = 0, _longPress = 0;

  @override
  Widget build(BuildContext context) {
    final favColor = _favorite ? AppColors.success : AppColors.primary;

    return DemoScaffold(
      body: ScrollPage([
        const IdentityCard(),
        const SizedBox(height: 16),
        sectionTitle('A. InkWell dengan Efek Ripple'),
        const SizedBox(height: 4),
        hint('InkWell memberi efek ripple Material saat ditekan.'),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(16),
          onTap: () {
            setState(() => _favorite = !_favorite);
            showMsg(context,
                _favorite ? 'Course ditandai favorite' : 'Favorite dibatalkan',
                color: _favorite ? AppColors.success : AppColors.primary);
          },
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _favorite
                    ? AppColors.success.withValues(alpha: 0.2)
                    : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.book_outlined, color: favColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Responsive Layout',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                    _favorite
                        ? 'Ditandai sebagai favorite'
                        : 'Tap untuk menandai favorite',
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ]),
            ),
            Icon(_favorite ? Icons.star : Icons.star_border,
                color: _favorite ? AppColors.success : AppColors.muted, size: 26),
          ]),
        ),
        const SizedBox(height: 24),
        sectionTitle('B. GestureDetector (Tap & Long Press)'),
        const SizedBox(height: 4),
        hint('GestureDetector mendeteksi gesture umum TANPA efek ripple Material.'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() => _tap++);
            showMsg(context, 'Tap terdeteksi ($_tap kali)');
          },
          onLongPress: () {
            setState(() => _longPress++);
            showMsg(context, 'Long press terdeteksi ($_longPress kali)');
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Column(children: [
              const Icon(Icons.touch_app, size: 40, color: AppColors.primary),
              const SizedBox(height: 10),
              const Text('Tap atau Long Press di sini',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
              const SizedBox(height: 6),
              Text('Tap: $_tap   •   Long Press: $_longPress',
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ]),
          ),
        ),
        const SizedBox(height: 24),
        sectionTitle('C. Jenis-jenis Button Material'),
        const SizedBox(height: 4),
        hint('Elevated (menonjol), Outlined (garis tepi), Text (teks saja).'),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            ElevatedButton.icon(
              onPressed: () => showMsg(context, 'ElevatedButton ditekan'),
              icon: const Icon(Icons.thumb_up, size: 18),
              label: const Text('ElevatedButton'),
              style: filled(AppColors.primary, pad: 12),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => showMsg(context, 'OutlinedButton ditekan'),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('OutlinedButton'),
              style: outlined(AppColors.primary, pad: 12),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => showMsg(context, 'TextButton ditekan'),
              icon: const Icon(Icons.info_outline, size: 18),
              label: const Text('TextButton'),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ]),
        ),
        const SizedBox(height: 24),
        sectionTitle('Kapan Pakai Apa?'),
        const SizedBox(height: 8),
        ruleCard(const [
          RuleRow(Icons.star, AppColors.primary, 'ElevatedButton',
              'Aksi utama (submit, save, konfirmasi)'),
          RuleRow(Icons.crop_square, AppColors.primary, 'OutlinedButton',
              'Aksi sekunder (batal, edit, alternatif)'),
          RuleRow(Icons.text_fields, AppColors.muted, 'TextButton',
              'Aksi tersier (link, "lihat selengkapnya")'),
          RuleRow(Icons.touch_app, AppColors.warn, 'InkWell',
              'Elemen Material yang perlu ripple + onTap'),
          RuleRow(Icons.gesture, AppColors.success, 'GestureDetector',
              'Gesture kustom (long press, drag, pan)'),
        ]),
      ]),
    );
  }
}

class FeedbackFormPage extends StatefulWidget {
  const FeedbackFormPage({super.key});

  @override
  State<FeedbackFormPage> createState() => _FeedbackFormPageState();
}

class _FeedbackFormPageState extends State<FeedbackFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(text: studentName);
  final _nim = TextEditingController(text: studentId);
  final _comment = TextEditingController();

  bool _autoValidate = false;
  ({String name, String nim, String comment})? _sent;

  @override
  void dispose() {
    _name.dispose();
    _nim.dispose();
    _comment.dispose();
    super.dispose();
  }

  String? _required(String? v, String label, int min) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return '$label wajib diisi';
    if (t.length < min) return '$label minimal $min karakter';
    return null;
  }

  String? _vName(String? v) => _required(v, 'Nama', 3);
  String? _vComment(String? v) => _required(v, 'Komentar', 5);
  String? _vNim(String? v) =>
      _required(v, 'NIM', 5) ??
      (RegExp(r'^\d+$').hasMatch(v!.trim()) ? null : 'NIM hanya boleh berisi angka');

  void _submit() {
    final ok = _formKey.currentState!.validate();
    setState(() {
      _autoValidate = true;
      _sent = ok
          ? (name: _name.text.trim(), nim: _nim.text.trim(), comment: _comment.text.trim())
          : null;
    });
    if (ok) {
      FocusScope.of(context).unfocus();
      showMsg(context,
          'Terima kasih, ${_name.text.trim()}! Feedback Anda sudah terkirim.',
          color: AppColors.success);
    } else {
      showMsg(context, 'Mohon periksa kembali field yang bertanda merah.',
          color: Colors.red);
    }
  }

  void _reset() {
    _formKey.currentState?.reset();
    _name.text = studentName;
    _nim.text = studentId;
    _comment.clear();
    setState(() {
      _autoValidate = false;
      _sent = null;
    });
  }

  Widget _field(TextEditingController c, String label, IconData icon,
          String? Function(String?) validator,
          {TextInputType? type, int lines = 1, String? hintText, bool last = false}) =>
      TextFormField(
        controller: c,
        keyboardType: type,
        maxLines: lines,
        validator: validator,
        textInputAction: last ? TextInputAction.newline : TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          alignLabelWithHint: lines > 1,
          isDense: true,
          prefixIcon: Icon(icon, size: 20),
          border: const OutlineInputBorder(),
        ),
      );

  Widget _previewRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.black54))),
          Expanded(
            child: Text(value.isEmpty ? '-' : value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) => DemoScaffold(
        body: ScrollPage([
          Form(
            key: _formKey,
            autovalidateMode: _autoValidate
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const IdentityCard(),
              const SizedBox(height: 16),
              sectionTitle('Form Feedback'),
              const SizedBox(height: 4),
              hint('Semua field wajib diisi. Nama minimal 3 karakter, NIM hanya '
                  'angka, dan komentar minimal 5 karakter.'),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  _field(_name, 'Nama Lengkap', Icons.person_outline, _vName),
                  const SizedBox(height: 12),
                  _field(_nim, 'NIM', Icons.badge_outlined, _vNim,
                      type: TextInputType.number),
                  const SizedBox(height: 12),
                  _field(_comment, 'Komentar', Icons.description_outlined, _vComment,
                      lines: 4,
                      hintText: 'Tulis feedback Anda (min. 5 karakter)',
                      last: true),
                ]),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reset'),
                    style: outlined(AppColors.primary, pad: 12),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Kirim Feedback'),
                    style: filled(AppColors.primary, pad: 12),
                  ),
                ),
              ]),
            ]),
          ),
          if (_sent != null) ...[
            const SizedBox(height: 16),
            AppCard(
              borderColor: AppColors.success.withValues(alpha: 0.4),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  SizedBox(width: 8),
                  Text('Data Terkirim',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.success)),
                ]),
                const SizedBox(height: 10),
                _previewRow('Nama', _sent!.name),
                _previewRow('NIM', _sent!.nim),
                _previewRow('Komentar', _sent!.comment),
              ]),
            ),
          ],
          const SizedBox(height: 16),
          AppCard(
            borderColor: AppColors.primary.withValues(alpha: 0.3),
            child: hint(
                'Form + GlobalKey<FormState> memvalidasi semua field sekaligus '
                'lewat _formKey.currentState!.validate(). Tiap TextFormField punya validator sendiri.'),
          ),
        ]),
      );
}



class FeedbackDemoPage extends StatefulWidget {
  const FeedbackDemoPage({super.key});

  @override
  State<FeedbackDemoPage> createState() => _FeedbackDemoPageState();
}

class _FeedbackDemoPageState extends State<FeedbackDemoPage> {
  String _last = '-';

  void _snack() {
    setState(() => _last = 'SnackBar ditampilkan');
    showMsg(context, 'Data berhasil disimpan.',
        color: AppColors.success,
        action: SnackBarAction(
          label: 'Lihat',
          textColor: Colors.white,
          onPressed: () => showMsg(context, 'Aksi "Lihat" dipilih.'),
        ));
  }

  Future<void> _confirm() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text(
            'Apakah Anda yakin ingin menghapus data ini? Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    final yes = ok == true;
    setState(() => _last = yes ? 'Data dihapus (dikonfirmasi)' : 'Penghapusan dibatalkan');
    showMsg(context, yes ? 'Data berhasil dihapus.' : 'Penghapusan dibatalkan.',
        color: yes ? Colors.red : AppColors.primary);
  }

  Future<void> _loading() async {
    setState(() => _last = 'Loading...');
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: AppCard(
            padding: EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat data...', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Mohon tunggu sebentar',
                  style: TextStyle(fontSize: 12, color: Colors.black54)),
            ]),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop();
    setState(() => _last = 'Data berhasil dimuat');
    showMsg(context, 'Data berhasil dimuat.', color: AppColors.success);
  }

  @override
  Widget build(BuildContext context) => DemoScaffold(
        body: ScrollPage([
          const IdentityCard(),
          const SizedBox(height: 16),
          sectionTitle('Umpan Balik ke Pengguna'),
          const SizedBox(height: 4),
          hint('SnackBar untuk feedback singkat, AlertDialog untuk konfirmasi, '
              'dan CircularProgressIndicator untuk loading.'),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              ElevatedButton.icon(
                onPressed: _snack,
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Simpan Data (SnackBar)'),
                style: filled(AppColors.primary),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _confirm,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Hapus Data (Dialog)'),
                style: outlined(Colors.red),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _loading,
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Muat Data (Loading)'),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          AppCard(
            borderColor: AppColors.primary.withValues(alpha: 0.3),
            child: Row(children: [
              const Icon(Icons.history, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Aksi terakhir:',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 2),
                  Text(_last,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          sectionTitle('Kapan Pakai Apa?'),
          const SizedBox(height: 8),
          ruleCard(const [
            RuleRow(Icons.notifications_active, AppColors.success, 'SnackBar',
                'Feedback singkat, tidak memblokir. Contoh: "Data tersimpan".'),
            RuleRow(Icons.help_outline, AppColors.warn, 'AlertDialog',
                'Konfirmasi/perhatian, memblokir sampai user respon.'),
            RuleRow(Icons.hourglass_top, AppColors.primary, 'Loading Indicator',
                'Operasi yang butuh waktu. Contoh: "Memuat data...".'),
          ]),
        ]),
      );
}


// DEBUGGING CHALLENGE
List<Widget> _bugActions(bool bug, ValueChanged<bool> onChanged) => [
      Text(bug ? 'BUG' : 'FIXED',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      Switch(
        value: bug,
        activeThumbColor: Colors.white,
        activeTrackColor: AppColors.warn,
        onChanged: onChanged,
      ),
    ];

class DebugChallengePage extends StatelessWidget {
  const DebugChallengePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cases = <(String, String, IconData, Widget)>[
      ('Kasus A', 'RenderFlex overflow: Row + teks panjang',
          Icons.view_column, const DebugCaseAPage()),
      ('Kasus B', 'ListView di dalam Column (unbounded height)',
          Icons.view_list, const DebugCaseBPage()),
      ('Kasus C', 'Keyboard overflow pada form di bawah layar',
          Icons.keyboard, const DebugCaseCPage()),
      ('Kasus D', 'Navigasi ganda (double push)',
          Icons.double_arrow, const DebugCaseDPage()),
    ];

    return DemoScaffold(
      body: ScrollPage([
        const IdentityCard(),
        const SizedBox(height: 16),
        sectionTitle('Debugging Challenge'),
        const SizedBox(height: 4),
        hint('Tiap kasus punya switch BUG/FIXED di AppBar untuk '
            'membandingkan error dan perbaikannya.'),
        const SizedBox(height: 12),
        for (final c in cases)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: Icon(c.$3, color: AppColors.warn),
                title: Text('${c.$1}: ${c.$2}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => go(context, c.$4),
              ),
            ),
          ),
      ]),
    );
  }
}


// KASUS A: RenderFlex overflow pada Row dengan teks panjang
class DebugCaseAPage extends StatefulWidget {
  const DebugCaseAPage({super.key});

  @override
  State<DebugCaseAPage> createState() => _DebugCaseAPageState();
}

class _DebugCaseAPageState extends State<DebugCaseAPage> {
  bool _bug = true;

  @override
  Widget build(BuildContext context) {
    const longText = '$studentId - $studentName - teks sangat panjang yang '
        'tidak akan muat dalam satu baris pada layar kecil sehingga harus '
        'dibungkus ke baris berikutnya';

    // BUG: Text di dalam Row mendapat lebar tak terbatas -> overflow.
    final buggy = Row(children: const [
      Icon(Icons.info, color: AppColors.primary),
      SizedBox(width: 8),
      Text(longText),
    ]);

    // FIXED: Expanded membatasi lebar Text = sisa ruang Row, lalu teks wrap.
    final fixed = Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [
      Icon(Icons.info, color: AppColors.primary),
      SizedBox(width: 8),
      Expanded(child: Text(longText)),
    ]);

    return DemoScaffold(
      actions: _bugActions(_bug, (v) => setState(() => _bug = v)),
      body: ScrollPage([
        const IdentityCard(),
        const SizedBox(height: 16),
        sectionTitle('Kasus A - RenderFlex Overflow'),
        const SizedBox(height: 4),
        hint(_bug
            ? 'BUG: Row memberi Text lebar tak terbatas. Muncul garis '
                'kuning-hitam dan error "RenderFlex overflowed".'
            : 'FIXED: Expanded membuat Text hanya memakai sisa lebar Row, '
                'sehingga teks otomatis turun ke baris berikutnya.'),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(16),
          borderColor: (_bug ? AppColors.warn : AppColors.success)
              .withValues(alpha: 0.5),
          child: _bug ? buggy : fixed,
        ),
      ]),
    );
  }
}

// KASUS B: Vertical viewport was given unbounded height
class DebugCaseBPage extends StatefulWidget {
  const DebugCaseBPage({super.key});

  @override
  State<DebugCaseBPage> createState() => _DebugCaseBPageState();
}

class _DebugCaseBPageState extends State<DebugCaseBPage> {
  @override
  Widget build(BuildContext context) {
    final list = ListView.builder(
      itemCount: 20,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AppCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primarySoft,
              child: Text('${i + 1}', style: const TextStyle(fontSize: 12)),
            ),
            title: Text('Item ke-${i + 1}'),
          ),
        ),
      ),
    );

    return DemoScaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const IdentityCard(),
          const SizedBox(height: 12),
          sectionTitle('Kasus B - Unbounded Height (FIXED)'),
          const SizedBox(height: 4),
          hint('FIXED: ListView dibungkus Expanded sehingga tingginya = sisa '
              'ruang Column dan dapat di-scroll sendiri.'),
          const SizedBox(height: 8),
          Expanded(child: list),
        ]),
      ),
    );
  }
}

// KASUS C: Keyboard overflow
class DebugCaseCPage extends StatefulWidget {
  const DebugCaseCPage({super.key});

  @override
  State<DebugCaseCPage> createState() => _DebugCaseCPageState();
}

class _DebugCaseCPageState extends State<DebugCaseCPage> {
  bool _bug = true;

  @override
  Widget build(BuildContext context) {
    final gap = MediaQuery.sizeOf(context).height * 0.4;

    final content = <Widget>[
      const IdentityCard(),
      const SizedBox(height: 12),
      sectionTitle('Kasus C - Keyboard Overflow'),
      const SizedBox(height: 4),
      hint(_bug
          ? 'BUG: Column biasa tanpa scroll. Saat keyboard muncul, tinggi body '
              'mengecil dan Column overflow (garis kuning-hitam).'
          : 'FIXED: isi dibungkus SingleChildScrollView (ScrollPage), sehingga '
              'form tetap bisa di-scroll dan field aktif terlihat.'),
      SizedBox(height: gap),
      AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Nama',
              isDense: true,
              prefixIcon: const Icon(Icons.person_outline, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Komentar',
              alignLabelWithHint: true,
              isDense: true,
              prefixIcon: const Icon(Icons.description_outlined, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ]),
      ),
    ];

    return DemoScaffold(
      actions: _bugActions(_bug, (v) => setState(() => _bug = v)),
      body: _bug
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: content),
            )
          : ScrollPage(content),
    );
  }
}

// KASUS D: Navigasi ganda (route ter-push berkali-kali)
class DebugCaseDPage extends StatefulWidget {
  const DebugCaseDPage({super.key});

  @override
  State<DebugCaseDPage> createState() => _DebugCaseDPageState();
}

class _DebugCaseDPageState extends State<DebugCaseDPage> {
  bool _bug = true;
  bool _busy = false; 
  int _active = 0; 

  Future<void> _open() async {
    if (!_bug && _busy) return;

    int n = 0;
    setState(() {
      _active++;
      n = _active;
      if (!_bug) _busy = true;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _DoublePushTarget(n: n)),
    );

    if (!mounted) return;
    setState(() {
      _active--;
      _busy = false; 
    });
  }

  @override
  Widget build(BuildContext context) => DemoScaffold(
        actions: _bugActions(_bug, (v) => setState(() => _bug = v)),
        body: ScrollPage([
          const IdentityCard(),
          const SizedBox(height: 16),
          sectionTitle('Kasus D - Navigasi Ganda'),
          const SizedBox(height: 4),
          hint(_bug
              ? 'BUG: Tekan tombol beberapa kali dengan cepat. Setiap tap memanggil '
                  'Navigator.push sehingga halaman tujuan dapat menumpuk. '
              : 'FIXED: Setelah satu navigasi dimulai, _busy menjadi true sehingga '
                  'tap berikutnya diabaikan sampai halaman tujuan ditutup.'),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(16),
            borderColor: (_bug ? AppColors.warn : AppColors.success)
                .withValues(alpha: 0.5),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                const Icon(Icons.layers, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Halaman tujuan yang menumpuk: $_active',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: (!_bug && _busy) ? null : _open,
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Buka Halaman Tujuan'),
                style: filled(_bug ? AppColors.warn : AppColors.success),
              ),
            ]),
          ),
        ]),
      );
}

class _DoublePushTarget extends StatelessWidget {
  final int n;
  const _DoublePushTarget({required this.n});

  @override
  Widget build(BuildContext context) => DemoScaffold(
        body: ScrollPage([
          const IdentityCard(),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Halaman tujuan ke-$n',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.primary)),
              const SizedBox(height: 6),
              hint(n > 1
                  ? 'Ada $n halaman bertumpuk. Itu bukti navigasi ganda.'
                  : 'Hanya satu halaman. Navigasi normal.'),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Kembali'),
                style: filled(AppColors.primary, pad: 12),
              ),
            ]),
          ),
        ]),
      );
}

// ===== APP =====

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: appTitle,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.bg,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.success,
          ),
        ),
        home: const MainShellPage(),
      );
}

void main() => runApp(const MyApp());