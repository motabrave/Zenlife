import 'package:an_giac/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import '../utils/calc.dart';
import '../models/wellness_entry.dart';
import '../services/storage.dart';
import '../widgets/animated_mood_icon.dart';
import 'result_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sweet_input_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Cấu hình từng nhóm đồ ngọt
class SweetGroupSpec {
  final String key;
  final String name;
  final SweetUnit unit; // ml hoặc g
  final List<int> presets; // các option dung tích/khối lượng gợi ý (ml/g)
  final double sugarPer100; // gram đường trên 100ml hoặc 100g
  final String note;

  const SweetGroupSpec({
    required this.key,
    required this.name,
    required this.unit,
    required this.presets,
    required this.sugarPer100,
    this.note = '',
  });
}

enum SweetUnit { ml, g }

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _storage = StorageService();

  // ------------------ LỊCH & BIỂU ĐỒ ------------------
  DateTime _selectedDate = DateTime.now();
  List<WellnessEntry> _recent = [];
  int _streakCurrent = 0;
  int _streakBest = 0;

  // ------------------ INPUT TRẠNG THÁI ------------------
  // stress, ngủ
  int _stress = 0;
  TimeOfDay? _sleep;
  TimeOfDay? _wake;
  final _notesCtrl = TextEditingController();

  // Nhóm đồ ngọt: mỗi nhóm có {quantity, sizeValue}
  // quantity: số phần (ly/cái/gói...)
  // sizeValue: dung tích (ml) hoặc khối lượng (g) cho MỖI phần
  final Map<String, Map<String, int>> _sweetInputs = {};

  late final AnimationController _chartAnim =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  // ------------------ CẤU HÌNH NHÓM (có TODO để bạn update dần) ------------------
  // sugarPer100: gram đường / 100ml (đồ uống) hoặc / 100g (đồ ăn)
  // Các số dưới là ước tính/trung bình — bạn cập nhật theo bảng tham chiếu của bạn.
  static const List<SweetGroupSpec> _groups = [
    SweetGroupSpec(
      key: 'soda',
      name: 'Nước ngọt có gas',
      unit: SweetUnit.ml,
      presets: [180, 250, 300, 330, 390, 500], // ml
      sugarPer100: 10.6, // TODO: cập nhật theo thương hiệu
      note: 'Ước tính trung bình ~10–11 g/100ml.',
    ),
    SweetGroupSpec(
      key: 'energy',
      name: 'Nước tăng lực',
      unit: SweetUnit.ml,
      presets: [250, 330, 500],
      sugarPer100: 12.9, // trung bình nhóm
      note: 'Trung bình nhóm ~12.9 g/100ml.',
    ),
    SweetGroupSpec(
      key: 'milk_tea',
      name: 'Trà sữa / pha chế',
      unit: SweetUnit.ml,
      presets: [300, 500, 700],
      sugarPer100: 8.5, // TODO: ước tính, bạn chỉnh theo dữ liệu của bạn
      note: 'Tùy cửa hàng/công thức, chỉnh theo nghiên cứu của bạn.',
    ),
    SweetGroupSpec(
      key: 'juice',
      name: 'Nước ép / sinh tố',
      unit: SweetUnit.ml,
      presets: [250, 350, 450, 500],
      sugarPer100: 9.0, // TODO: với nước ép đóng hộp có thêm đường -> cập nhật
      note: 'Nếu 100% ép không thêm đường: giảm hệ số.',
    ),
    SweetGroupSpec(
      key: 'candy',
      name: 'Kẹo (ngậm/mút/dẻo)',
      unit: SweetUnit.g,
      presets: [5, 10, 20, 30], // g mỗi viên/gói
      sugarPer100: 70.0, // TODO: ước tính 70g đường / 100g
      note: '1 viên kẹo ngậm ≈ 5g.',
    ),
    SweetGroupSpec(
      key: 'chocolate',
      name: 'Socola / thanh kẹo',
      unit: SweetUnit.g,
      presets: [35, 38, 45, 50], // Snickers/KitKat...
      sugarPer100: 50.0, // TODO: chỉnh từng loại
      note: 'VD Snickers 35g, KitKat 38g.',
    ),
    SweetGroupSpec(
      key: 'cookies',
      name: 'Bánh ngọt / bánh quy',
      unit: SweetUnit.g,
      presets: [60, 120], // Cosy nhỏ/lớn
      sugarPer100: 32.0, // TODO: cập nhật theo nhãn
      note: 'Cosy nhỏ 50–60g; lớn ~120g.',
    ),
    SweetGroupSpec(
      key: 'icecream_yogurt',
      name: 'Kem / sữa chua',
      unit: SweetUnit.g,
      presets: [70, 100, 120], // kem que 60–80g, sữa chua 100g
      sugarPer100: 20.0, // TODO
      note: '1 hộp sữa chua ~100g; kem que 60–80g.',
    ),
    SweetGroupSpec(
      key: 'sweet_snack',
      name: 'Bánh gạo, snack ngọt',
      unit: SweetUnit.g,
      presets: [20, 40, 60, 80],
      sugarPer100: 25.0, // TODO
      note: 'VD bánh gạo phủ đường.',
    ),
    SweetGroupSpec(
      key: 'traditional',
      name: 'Đồ ngọt truyền thống (chè, xôi...)',
      unit: SweetUnit.g,
      presets: [150, 200, 250], // ước tính khẩu phần
      sugarPer100: 14.0, // TODO: ước tính đường / 100g
      note: 'Tùy món, bạn cập nhật thêm.',
    ),
    SweetGroupSpec(
      key: 'preserve',
      name: 'Mứt, siro, mật ong, trái cây sấy',
      unit: SweetUnit.g,
      presets: [15, 30, 50, 100],
      sugarPer100: 70.0, // 100% free sugar (ước tính)
      note: 'Tỉ lệ đường rất cao.',
    ),
    // Trái cây nguyên quả KHÔNG tính free sugar -> không đưa vào
  ];

  // ------------------ LIFECYCLE ------------------
  @override
  void initState() {
    super.initState();
    for (final g in _groups) {
      _sweetInputs[g.key] = {"qty": 0, "size": g.presets.first};
    }
    _loadRecent();
  }

  @override
  void dispose() {
    _chartAnim.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isSleep}) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
    );

    if (picked != null) {
      setState(() {
        if (isSleep) {
          _sleep = picked;
        } else {
          _wake = picked;
        }
      });
    }
  }

  Future<void> _loadRecent() async {
    final all = await _storage.getAllEntries(); // giả định đã có
    // Lọc 15 ngày gần nhất
    final cutoff = DateTime.now().subtract(const Duration(days: 15));
    _recent = all.where((e) => e.date.isAfter(cutoff)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    _calcStreak(all);
    if (mounted) {
      setState(() {});
      _chartAnim.forward(from: 0);
    }
  }

  void _calcStreak(List<WellnessEntry> all) {
    if (all.isEmpty) {
      _streakCurrent = 0;
      _streakBest = 0;
      return;
    }
    all.sort((a, b) => a.date.compareTo(b.date));
    int best = 1;
    int cur = 1;
    for (int i = 1; i < all.length; i++) {
      final prev = DateUtils.dateOnly(all[i - 1].date);
      final now = DateUtils.dateOnly(all[i].date);
      if (now.difference(prev).inDays == 1) {
        cur++;
        if (cur > best) best = cur;
      } else if (now.isAtSameMomentAs(prev)) {
        // cùng ngày -> bỏ qua
      } else {
        cur = 1;
      }
    }
    // Nếu hôm nay đã nhập -> chuỗi hiện tại = cur nếu liền kề hôm qua
    final last = DateUtils.dateOnly(all.last.date);
    final today = DateUtils.dateOnly(DateTime.now());
    if (today.difference(last).inDays == 1) {
      _streakCurrent = cur;
    } else if (today.isAtSameMomentAs(last)) {
      _streakCurrent = cur; // đã nhập hôm nay
    } else {
      _streakCurrent = 0; // bị đứt
    }
    _streakBest = best;
  }

  // ------------------ TÍNH TOÁN ĐƯỜNG & ĐIỂM ------------------
  // Trả về tổng GRAM đường (free sugar ~ ước tính) từ các nhóm
  double _totalSugarGrams() {
    double total = 0;
    for (final g in _groups) {
      final qty = (_sweetInputs[g.key]!["qty"] ?? 0).toDouble();
      if (qty <= 0) continue;
      final size = (_sweetInputs[g.key]!["size"] ?? g.presets.first).toDouble();

      // gram đường trong 1 phần = size * (sugarPer100 / 100)
      // đồ uống: size = ml; đồ ăn: size = g
      final sugarPerServing = size * (g.sugarPer100 / 100.0);
      total += qty * sugarPerServing;
    }
    return total;
  }

  /// Quy đổi từ gram đường ra "sweetUnits" để dùng lại với CalcUtils cũ
  /// Mặc định: 10 gram đường ~ 1 "đơn vị ngọt".
  /// Bạn có thể đổi tỉ lệ này nếu muốn nhạy hơn / nhẹ hơn.
  int _sugarToSweetUnits(double sugarGrams) {
    return (sugarGrams / 10.0).round(); // TODO: tinh chỉnh
  }

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _computeAndSave() async {
    if (_sleep == null || _wake == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn giờ ngủ và giờ dậy')),
      );
      return;
    }

    final sugarG = _totalSugarGrams();
    final sweetUnits = _sugarToSweetUnits(sugarG);

    final sleepMin = _toMinutes(_sleep!);
    final wakeMin = _toMinutes(_wake!);
    final hours = CalcUtils.hoursBetween(sleepMin, wakeMin);

    final score = CalcUtils.computeScore(
      sweetUnits: sweetUnits,
      stressLevel: _stress,
      hoursSlept: hours,
    );

    final entry = WellnessEntry(
      date: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      ),
      sweetUnits: sweetUnits,
      stressLevel: _stress,
      sleepMinutes: sleepMin,
      wakeMinutes: wakeMin,
      hoursSlept: hours,
      score: score,
      notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text.trim(),
    );

    await _storage.addEntry(entry);
    await _loadRecent();

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(entry: entry)),
    );
  }

  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    final sugarG = _totalSugarGrams();
    final sweetUnits = _sugarToSweetUnits(sugarG);
    final instantScorePreview =
    (100 - (sweetUnits * 5 + _stress * 3)).clamp(0, 100);

    return Scaffold(
      appBar: _buildAppBar(context, instantScorePreview),
      body: Column(
        children: [
          // 🔹 NỘI DUNG CHÍNH
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ChartCard(entries: _recent, controller: _chartAnim),
                  const SizedBox(height: 16),
                  _CalendarCard(
                    selected: _selectedDate,
                    onChanged: (d) => setState(() => _selectedDate = d),
                  ),
                  const SizedBox(height: 16),
                  _EntryFormCard(
                    groups: _groups,
                    inputs: _sweetInputs,
                    stress: _stress,
                    sleep: _sleep,
                    wake: _wake,
                    notesCtrl: _notesCtrl,
                    onStressChanged: (v) => setState(() => _stress = v),
                    onPickSleep: () => _pickTime(isSleep: true),
                    onPickWake: () => _pickTime(isSleep: false),
                    sugarPreview: sugarG,
                    sweetUnitsPreview: sweetUnits,
                    scorePreview: instantScorePreview.toInt(),
                    onChangeQty: (key, qty) {
                      setState(() => _sweetInputs[key]!['qty'] = qty);
                    },
                    onChangeSize: (key, size) {
                      setState(() => _sweetInputs[key]!['size'] = size);
                    },
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _computeAndSave,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text("Tính & Lưu"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  PreferredSizeWidget _buildAppBar(BuildContext context, int scorePreview) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProfileScreen()),
          );
        },
      ),
      title: Row(
        children: [
          const Text(
            "Zenlife",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'iCielCadena',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          AnimatedMoodIcon(score: scorePreview, size: 28),
          const Spacer(),
          // Streak pill
          _StreakPill(current: _streakCurrent, best: _streakBest),
        ],
      ),
    );
  }
}

//-------------------------------------------------------------------------------------------------//
//---------------------------------------------BIỂU ĐỒ---------------------------------------------//
//-------------------------------------------------------------------------------------------------//
class _ChartCard extends StatelessWidget {
  final List<WellnessEntry> entries;
  final AnimationController controller;

  const _ChartCard({required this.entries, required this.controller});

  @override
  Widget build(BuildContext context) {
    final days = _buildDaySeries(entries);

    return Card(
      color: Colors.white.withOpacity(0.08), // nền trong suốt mờ
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.purpleAccent.withOpacity(0.3), // viền tím nhẹ
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF8B5CF6), // tím neon
                      Color(0xFFEC4899), // hồng galaxy
                      Color(0xFF3B82F6), // xanh dương neon
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    "Xu hướng gần đây",
                    style: GoogleFonts.exo2(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 12,
                            color: Color(0xFF8B5CF6), // tím glow
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.auto_graph,
                  color: Color(0xFFD8B4FE), // tím neon pastel
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Biểu đồ
            SizedBox(
              height: 180,
              child: AnimatedBuilder(
                animation: controller,
                builder: (ctx, _) {
                  final t = Curves.easeOutCubic.transform(
                    controller.value.clamp(0.0, 1.0),
                  );
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final d in days) ...[
                        Expanded(
                          child: _Bar(
                            value: d.score / 100.0 * t,
                            label: d.label,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ]
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_DayPoint> _buildDaySeries(List<WellnessEntry> entries) {
    final Map<DateTime, int> map = {};
    for (final e in entries) {
      map[DateUtils.dateOnly(e.date)] = e.score;
    }

    final now = DateUtils.dateOnly(DateTime.now());
    final from = now.subtract(const Duration(days: 6));
    final result = <_DayPoint>[];

    for (int i = 0; i <= 6; i++) {
      final d = from.add(Duration(days: i));
      final s = map[d] ?? 0;

      result.add(_DayPoint(
        label: _weekdayLabel(d.weekday), // đổi ở đây
        score: s,
      ));
    }
    return result;
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return "T2";
      case DateTime.tuesday:
        return "T3";
      case DateTime.wednesday:
        return "T4";
      case DateTime.thursday:
        return "T5";
      case DateTime.friday:
        return "T6";
      case DateTime.saturday:
        return "T7";
      case DateTime.sunday:
        return "CN";
      default:
        return "";
    }
  }
}

class _DayPoint {
  final String label;
  final int score;
  _DayPoint({required this.label, required this.score});
}

class _Bar extends StatelessWidget {
  final double value; // 0..1
  final String label;
  const _Bar({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Cột
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              height: (value.clamp(0.0, 1.0)) * 140,
              width: 14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE0C3FC),
                    Color(0xFF8EC5FC),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Nhãn
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

//---------------------------Lich---------------------------//
class _CalendarCard extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onChanged;

  const _CalendarCard({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.white70),
                SizedBox(width: 8),
                Text("Chọn ngày muốn nhập",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  textTheme: Theme.of(context).textTheme.copyWith(
                    bodySmall: const TextStyle(fontSize: 0), // ẩn chữ cái đầu tuần
                  ),
                ),
                child: CalendarDatePicker(
                  initialDate: selected,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onDateChanged: onChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryFormCard extends StatelessWidget {
  final List<SweetGroupSpec> groups;
  final Map<String, Map<String, int>> inputs;

  final int stress;
  final TimeOfDay? sleep;
  final TimeOfDay? wake;
  final TextEditingController notesCtrl;

  final ValueChanged<int> onStressChanged;
  final VoidCallback onPickSleep;
  final VoidCallback onPickWake;

  final double sugarPreview; // gram
  final int sweetUnitsPreview;
  final int scorePreview;

  final void Function(String key, int qty) onChangeQty;
  final void Function(String key, int size) onChangeSize;

  const _EntryFormCard({
    required this.groups,
    required this.inputs,
    required this.stress,
    required this.sleep,
    required this.wake,
    required this.notesCtrl,
    required this.onStressChanged,
    required this.onPickSleep,
    required this.onPickWake,
    required this.sugarPreview,
    required this.sweetUnitsPreview,
    required this.scorePreview,
    required this.onChangeQty,
    required this.onChangeSize,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Nhập dữ liệu cho ngày đã chọn",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                AnimatedMoodIcon(score: scorePreview, size: 28),
              ],
            ),
            const SizedBox(height: 12),

            // ----- Nhóm đồ ngọt -----
            const Text("🍭 Đồ ngọt theo nhóm", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            for (final g in groups) ...[
              _SweetGroupTile(
                spec: g,
                qty: inputs[g.key]!['qty']!,
                size: inputs[g.key]!['size']!,
                onChangeQty: (v) => onChangeQty(g.key, v),
                onChangeSize: (v) => onChangeSize(g.key, v),
              ),
              const SizedBox(height: 8),
            ],

            // Tổng ước tính đường
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE7F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.opacity, color: Color(0xFF7E57C2)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Ước tính đường hôm nay: "
                          "${sugarPreview.toStringAsFixed(1)} g (~$sweetUnitsPreview đơn vị ngọt)",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ----- Stress -----
            Text("😵 Mức độ stress: $stress / 10"),
            Slider(
              value: stress.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              label: "$stress",
              onChanged: (v) => onStressChanged(v.round()),
            ),

            const SizedBox(height: 8),

            // ----- Giờ ngủ / dậy -----
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onPickSleep,
                    icon: const Icon(Icons.bedtime),
                    label: Text(sleep == null ? "Giờ ngủ" : "Ngủ: ${sleep!.format(context)}"),
                    style: _btnStyle(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onPickWake,
                    icon: const Icon(Icons.wb_sunny_outlined),
                    label: Text(wake == null ? "Giờ dậy" : "Dậy: ${wake!.format(context)}"),
                    style: _btnStyle(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ----- Ghi chú -----
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                labelText: "Ghi chú (nếu bạn có)",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _btnStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6C63FF),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}

class _SweetGroupTile extends StatelessWidget {
  final SweetGroupSpec spec;
  final int qty;
  final int size;
  final ValueChanged<int> onChangeQty;
  final ValueChanged<int> onChangeSize;

  const _SweetGroupTile({
    required this.spec,
    required this.qty,
    required this.size,
    required this.onChangeQty,
    required this.onChangeSize,
  });

  @override
  Widget build(BuildContext context) {
    final unitLabel = spec.unit == SweetUnit.ml ? "ml" : "g";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEDE7F6)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                spec.unit == SweetUnit.ml ? Icons.local_drink : Icons.cake,
                color: const Color(0xFF7E57C2),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  spec.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              // Stepper số lượng
              _QtyControl(qty: qty, onChanged: onChangeQty),
            ],
          ),
          if (qty > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Text("Dung tích/khối lượng mỗi phần: "),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: size,
                  items: [
                    for (final p in spec.presets)
                      DropdownMenuItem(value: p, child: Text("$p $unitLabel")),
                  ],
                  onChanged: (v) {
                    if (v != null) onChangeSize(v);
                  },
                ),
              ],
            ),
            if (spec.note.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "• ${spec.note}",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onChanged;

  const _QtyControl({required this.qty, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => onChanged((qty - 1).clamp(0, 20)),
            icon: const Icon(Icons.remove),
          ),
          Text("$qty", style: const TextStyle(fontWeight: FontWeight.w600)),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => onChanged((qty + 1).clamp(0, 20)),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  final int current;
  final int best;
  const _StreakPill({required this.current, required this.best});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 18),
          const SizedBox(width: 4),
          Text(
            "$current",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Text("Best $best", style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SettingTile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: () {},
    );
  }
}
