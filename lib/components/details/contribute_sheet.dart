import 'package:flutter/material.dart';

class ContributeSheet extends StatelessWidget {
  const ContributeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('投稿', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ContributeAction(Icons.edit, 'クチコミ', Colors.blue),
              _ContributeAction(Icons.photo_camera, '写真を追加', Colors.blue),
              _ContributeAction(Icons.location_on, '場所を追加', Colors.blue),
              _ContributeAction(Icons.rate_review, '編集を提案', Colors.blue),
            ],
          ),
          const SizedBox(height: 32),
          const Text('クチコミを投稿', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
            title: const Text('東京ミッドタウン'),
            subtitle: const Text('最近訪れましたか？'),
            trailing: const Icon(Icons.star_border, color: Colors.blue),
          ),
          const Divider(),
          const Text('ローカルガイドのレベル', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const ListTile(
            leading: Icon(Icons.stars, color: Colors.orange, size: 40),
            title: Text('レベル 4'),
            subtitle: Text('次のレベルまであと 250 ポイント'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _ContributeAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ContributeAction(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
      ],
    );
  }
}
