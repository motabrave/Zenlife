import 'package:flutter/material.dart';
import 'home_screen.dart';


class SweetInputScreen extends StatelessWidget {
  final List<SweetGroupSpec> groups;
  final Map<String, Map<String, int>> inputs;
  final void Function(String key, int qty) onChangeQty;
  final void Function(String key, int size) onChangeSize;

  const SweetInputScreen({
    required this.groups,
    required this.inputs,
    required this.onChangeQty,
    required this.onChangeSize,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đồ ngọt tiêu thụ"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, inputs),
            child: const Text("Xác nhận", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final g in groups) ...[
            Text(g.nameGroup, style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _SweetGroupTile(
              spec: g,
              qty: inputs[g.key]!['qty']!,
              size: inputs[g.key]!['size']!,
              onChangeQty: (v) => onChangeQty(g.key, v),
              onChangeSize: (v) => onChangeSize(g.key, v),
            ),
            const Divider(height: 24, color: Colors.white24),
          ]
        ],
      ),
    );
  }
}

