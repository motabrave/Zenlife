import 'package:flutter/material.dart';
import '../services/storage.dart';
import '../models/wellness_entry.dart';
import '../utils/calc.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _storage = StorageService();
  late Future<List<WellnessEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = _storage.loadEntries();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _storage.loadEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử')),
      body: FutureBuilder<List<WellnessEntry>>(
        future: _future,
        builder: (context, snapshot) {
          final data = snapshot.data ?? [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (data.isEmpty) {
            return const Center(child: Text("Chưa có dữ liệu — hãy ghi lại từ Trang chủ."));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final e = data[index];
                final band = CalcUtils.bandName(e.score);
                final color = e.score >= 80
                    ? Colors.green
                    : (e.score >= 50 ? Colors.amber : Colors.redAccent);
                return Dismissible(
                  key: ValueKey("${e.date.toIso8601String()}-$index"),
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Xóa bản ghi?"),
                            content: const Text("Bạn có chắc muốn xóa mục này?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Xóa")),
                            ],
                          ),
                        ) ?? false;
                  },
                  onDismissed: (_) async {
                    await _storage.deleteEntryAt(index);
                    await _refresh();
                  },
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: Theme.of(context).colorScheme.surface,
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.15),
                      child: Icon(Icons.stars, color: color),
                    ),
                    title: Text("${e.readableDate} — ${e.score}/100"),
                    subtitle: Text("Trạng thái: $band • Ngủ ${e.hoursSlept.toStringAsFixed(1)} giờ"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(entry: e)));
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
