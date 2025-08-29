import 'package:flutter/material.dart';
import '../models/wellness_entry.dart';
import '../utils/calc.dart';
import '../widgets/animated_mood_icon.dart';
import '../widgets/score_gauge.dart';

class ResultScreen extends StatelessWidget {
  final WellnessEntry entry;
  const ResultScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final advice = CalcUtils.adviceForScore(entry.score);
    final band = CalcUtils.bandName(entry.score);

    return Scaffold(
      appBar: AppBar(title: const Text("Kết quả hôm nay")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Phần có thể cuộn
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedMoodIcon(score: entry.score, size: 80),
                            const SizedBox(height: 12),
                            Text(
                              "Chỉ số An Giấc (${entry.readableDate})",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            ScoreGauge(score: entry.score),
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(band),
                              avatar: const Icon(Icons.stars),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              advice,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Thông tin đầu vào", style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            _row("Đồ ngọt", "${entry.sweetUnits}/10"),
                            _row("Stress", "${entry.stressLevel}/10"),
                            _row("Giờ ngủ", _fmt(entry.sleepMinutes)),
                            _row("Giờ dậy", _fmt(entry.wakeMinutes)),
                            _row("Tổng thời gian ngủ", "${entry.hoursSlept.toStringAsFixed(1)} giờ"),
                            if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text("Ghi chú: ${entry.notes!}"),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Nút ở cuối, không bị cuộn
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check),
              label: const Text("Xong"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String a, String b) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(a),
          Text(b, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _fmt(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return "$h:$m";
  }
}
