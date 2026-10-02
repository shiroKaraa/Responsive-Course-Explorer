import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// ===== IDENTITAS =====
const String studentName = 'I Kadek Dwi Bajaskara';
const String studentId = '2415051068';
const String appTitle = 'Worksheet Pertemuan 5';

class AppColors {
  static const primary = Color(0xFF1565C0);
  static const primarySoft = Color(0xFFE3F0FC);
  static const success = Color(0xFF2E7D32);
  static const warn = Color(0xFFEF6C00);
  static const muted = Color(0xFF607D8B);
  static const bg = Color(0xFFF5F8FC);
  static const border = Color(0xFFE3E8EF);
}

// ===== DATA & STATE BERSAMA =====

// Top-level variable bersifat lazy: JSON hanya dibaca sekali lalu dipakai ulang.
final Future<Map<String, dynamic>> studentDataFuture = rootBundle
    .loadString('assets/data/student_data.json')
    .then((s) => jsonDecode(s) as Map<String, dynamic>);

// Favorite dipakai bersama oleh tab Courses, halaman standalone, dan Profile.
final ValueNotifier<Set<String>> favorites = ValueNotifier(<String>{});

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

/// Kartu dasar. Material transparan di dalamnya membuat ripple InkWell
/// tampil DI ATAS warna kartu (kalau tidak, ripple tertutup warna putih).
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

/// Halaman scroll standar (Tahap 6): padding bawah ikut tinggi keyboard.
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

/// Baris "ikon - label ..... nilai" (dipakai Profile & Course Detail).
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

/// Baris "ikon + judul + deskripsi" (panduan "Kapan Pakai Apa?").
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

// ===== TAHAP 10 & 11: MAIN SHELL (NavigationBar <-> NavigationRail) =====

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;

  static const _pages = <Widget>[_HomeTabPage(), CourseGridPage(), _ProfileTabPage()];

  // Satu daftar destinasi dipakai oleh NavigationBar maupun NavigationRail.
  static const _dest = <(IconData, IconData, String)>[
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.school_outlined, Icons.school, 'Courses'),
    (Icons.person_outline, Icons.person, 'Profile'),
  ];

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 840;
        // Satu Scaffold + key pada konten: halaman aktif & state-nya tidak
        // hilang saat layout berpindah antara compact dan expanded.
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
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const IdentityCard(),
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
  const _StatTile(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Expanded(
        child: AppCard(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
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
            _StatTile(Icons.star_outline, 'Favorite', '${favs.length}'),
            const SizedBox(width: 10),
            const _StatTile(Icons.trending_up, 'Progress', '20%'),
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
            InfoRow(Icons.school_outlined, 'Program Studi', 'Pendidikan Teknik Informatika'),
            Divider(height: 20),
            InfoRow(Icons.calendar_today_outlined, 'Semester', '5'),
          ]),
        ),
        const SizedBox(height: 16),
        sectionTitle('Tentang Aplikasi'),
        const SizedBox(height: 8),
        AppCard(
          borderColor: AppColors.primary.withValues(alpha: 0.3),
          child: hint('Aplikasi ini adalah hasil praktikum Worksheet Pertemuan 5: '
              'Responsive Layout, Navigation & User Interaction. '
              'Nama dan NIM ditampilkan pada setiap tahap sebagai bukti identitas.'),
        ),
      ]);
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

// ===== TAHAP 4: EXPANDED, FLEXIBLE, WRAP =====

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

// ===== TAHAP 5, 8 & 9: GRIDVIEW RESPONSIF, DETAIL, FAVORITE =====

int columnsFor(double width) => width < 600 ? 1 : (width < 840 ? 2 : 3);

/// Tahap 9: await push -> terima hasil pop(result) -> update favorite.
Future<void> openCourse(BuildContext context, Map<String, dynamic> course) async {
  final code = course['code']?.toString() ?? '';
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => CourseDetailPage(
          course: course, isFavorite: favorites.value.contains(code)),
    ),
  );
  // null = tombol back biasa (tidak ada perubahan).
  if (result == null || !context.mounted) return;
  // Buat Set baru agar ValueNotifier memberi tahu pendengarnya.
  favorites.value = result
      ? {...favorites.value, code}
      : ({...favorites.value}..remove(code));
  showMsg(
    context,
    '${course['title'] ?? 'Course'} ${result ? 'ditandai sebagai favorite!' : 'dihapus dari favorite.'}',
    color: result ? AppColors.success : AppColors.primary,
  );
}

class CourseGridPage extends StatelessWidget {
  /// true  = dibuka via Navigator.push (dibungkus Scaffold sendiri)
  /// false = dipakai sebagai tab di dalam MainShellPage
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
        final courses = ((data['courses'] as List?) ?? []).cast<Map<String, dynamic>>();

        return ValueListenableBuilder<Set<String>>(
          valueListenable: favorites,
          builder: (context, favs, _) => LayoutBuilder(
            builder: (context, c) => Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: IdentityCard(
                  name: s['name'] ?? studentName,
                  nim: s['nim'] ?? studentId,
                  subtitle: '${s['program'] ?? 'Mahasiswa'} • Semester ${s['semester'] ?? '-'}',
                ),
              ),
              if (favs.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    borderColor: AppColors.warn.withValues(alpha: 0.4),
                    child: Row(children: [
                      const Icon(Icons.star, color: AppColors.warn, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Favorite: ${favs.join(', ')}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warn)),
                      ),
                    ]),
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
                  itemBuilder: (_, i) => CourseCard(
                    course: courses[i],
                    isFavorite: favs.contains(courses[i]['code']?.toString() ?? ''),
                    onTap: () => openCourse(context, courses[i]),
                  ),
                ),
              ),
            ]),
          ),
        );
      },
    );

    return standalone ? DemoScaffold(body: content) : content;
  }
}

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isFavorite;
  final VoidCallback? onTap;
  const CourseCard({super.key, required this.course, this.isFavorite = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = course['status']?.toString() ?? 'planned';
    final color = StatusHelper.color(status);

    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      borderColor: isFavorite
          ? AppColors.warn.withValues(alpha: 0.6)
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
          if (isFavorite) const Icon(Icons.star, color: AppColors.warn, size: 18),
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
  const CourseDetailPage({super.key, required this.course, this.isFavorite = false});

  @override
  Widget build(BuildContext context) {
    String f(String k, [String d = '-']) => course[k]?.toString() ?? d;
    final status = f('status', 'planned');
    final color = StatusHelper.color(status);
    final credits = f('credits');

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
              Text('${f('code')} • $credits SKS',
                  style: const TextStyle(fontSize: 13, color: Colors.black54)),
              const Spacer(),
              StatusHelper.badge(status),
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
            InfoRow(Icons.tag, 'Kode', f('code')),
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
        // Tahap 9: hasil dikirim balik lewat pop(context, nilai).
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, !isFavorite),
          icon: Icon(isFavorite ? Icons.star_border : Icons.star, size: 18),
          label: Text(isFavorite
              ? 'Hapus dari Favorite & Kembali'
              : 'Tandai Favorite & Kembali'),
          style: filled(isFavorite ? AppColors.muted : AppColors.warn),
        ),
        const SizedBox(height: 12),
        AppCard(
          borderColor: AppColors.primary.withValues(alpha: 0.3),
          child: hint('Menekan tombol di atas memanggil Navigator.pop(context, ${!isFavorite}). '
              'Tombol back biasa mengembalikan null (tidak ada perubahan).'),
        ),
      ]),
    );
  }
}

// ===== TAHAP 6: SCROLL & KEYBOARD =====

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
      // Scroll OFF sengaja tanpa scroll view agar overflow bisa diamati.
      body: _useScroll
          ? ScrollPage(children)
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
            ),
    );
  }
}

// ===== TAHAP 7: Navigator.push() & pop() =====

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

// ===== TAHAP 12: INTERACTION (InkWell, GestureDetector, Button) =====

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
    final favColor = _favorite ? AppColors.warn : AppColors.primary;

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
            showMsg(context, _favorite ? 'Course ditandai favorite' : 'Favorite dibatalkan');
          },
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _favorite ? AppColors.warn.withValues(alpha: 0.2) : AppColors.primarySoft,
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
                Text(_favorite ? 'Ditandai sebagai favorite' : 'Tap untuk menandai favorite',
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ]),
            ),
            Icon(_favorite ? Icons.star : Icons.star_border,
                color: _favorite ? AppColors.warn : AppColors.muted, size: 26),
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

// ===== TAHAP 13: FORM & VALIDASI =====

class FeedbackFormPage extends StatefulWidget {
  const FeedbackFormPage({super.key});

  @override
  State<FeedbackFormPage> createState() => _FeedbackFormPageState();
}

class _FeedbackFormPageState extends State<FeedbackFormPage> {
  final _formKey = GlobalKey<FormState>();
  // Nama & NIM terisi default dari konstanta identitas.
  final _name = TextEditingController(text: studentName);
  final _nim = TextEditingController(text: studentId);
  final _comment = TextEditingController();

  bool _autoValidate = false;
  ({String name, String nim, String comment})? _sent; // null = belum terkirim

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
      // Preview hanya muncul bila SEMUA field valid.
      _sent = ok
          ? (name: _name.text.trim(), nim: _nim.text.trim(), comment: _comment.text.trim())
          : null;
    });
    if (ok) {
      FocusScope.of(context).unfocus();
      showMsg(context, 'Terima kasih, ${_name.text.trim()}! Feedback Anda sudah terkirim.',
          color: AppColors.success);
    } else {
      showMsg(context, 'Mohon periksa kembali field yang bertanda merah.', color: Colors.red);
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
                  _field(_nim, 'NIM', Icons.badge_outlined, _vNim, type: TextInputType.number),
                  const SizedBox(height: 12),
                  _field(_comment, 'Komentar', Icons.description_outlined, _vComment,
                      lines: 4, hintText: 'Tulis feedback Anda (min. 5 karakter)', last: true),
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
            child: hint('Form + GlobalKey<FormState> memvalidasi semua field sekaligus '
                'lewat _formKey.currentState!.validate(). Tiap TextFormField punya validator sendiri.'),
          ),
        ]),
      );
}

// ===== TAHAP 14: SNACKBAR, DIALOG, LOADING =====

class FeedbackDemoPage extends StatefulWidget {
  const FeedbackDemoPage({super.key});

  @override
  State<FeedbackDemoPage> createState() => _FeedbackDemoPageState();
}

class _FeedbackDemoPageState extends State<FeedbackDemoPage> {
  String _last = '-';

  void _snack() {
    setState(() => _last = 'SnackBar ditampilkan');
    showMsg(
      context,
      'Data berhasil disimpan.',
      color: AppColors.success,
      action: SnackBarAction(
        label: 'Lihat',
        textColor: Colors.white,
        onPressed: () => showMsg(context, 'Aksi "Lihat" dipilih.'),
      ),
    );
  }

  Future<void> _confirm() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text(
            'Apakah Anda yakin ingin menghapus data ini? Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
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
      // PopScope: tombol back tidak menutup dialog lebih awal (kalau tidak,
      // pop() di bawah akan ikut menutup halaman ini).
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
                'Feedback singkat, tidak memblokir. Contoh: "Data tersimpan", "Berhasil login".'),
            RuleRow(Icons.help_outline, AppColors.warn, 'AlertDialog',
                'Konfirmasi/perhatian, memblokir sampai user respon. Contoh: "Yakin hapus?".'),
            RuleRow(Icons.hourglass_top, AppColors.primary, 'Loading Indicator',
                'Operasi yang butuh waktu. Contoh: "Memuat data...", "Mengirim...".'),
          ]),
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
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        ),
        home: const MainShellPage(),
      );
}

void main() => runApp(const MyApp());