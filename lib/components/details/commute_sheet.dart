import 'package:flutter/material.dart';

class CommuteSheet extends StatelessWidget {
  const CommuteSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('移動', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildCommuteCard(
            '自宅へ',
            '15分',
            '混雑なし',
            Icons.home,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildCommuteCard(
            '職場へ',
            '35分',
            '一部で渋滞',
            Icons.work,
            Colors.brown,
          ),
          const SizedBox(height: 24),
          const Text('周辺の交通状況', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const ListTile(
            leading: Icon(Icons.traffic, color: Colors.red),
            title: Text('首都高速都心環状線'),
            subtitle: Text('事故による渋滞（2km）'),
          ),
          const ListTile(
            leading: Icon(Icons.train, color: Colors.orange),
            title: Text('山手線'),
            subtitle: Text('平常運転'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommuteCard(String title, String time, String status, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(status, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }
}
