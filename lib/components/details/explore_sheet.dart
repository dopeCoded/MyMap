import 'package:flutter/material.dart';

class ExploreSheet extends StatelessWidget {
  final ScrollController scrollController;

  const ExploreSheet({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        _buildHandle(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('最新の付近の情報', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 20),
        _buildExploreCategory(Icons.restaurant, 'レストラン', Colors.orange),
        _buildExploreCategory(Icons.local_cafe, 'カフェ', Colors.brown),
        _buildExploreCategory(Icons.local_gas_station, 'ガソリン', Colors.blue),
        _buildExploreCategory(Icons.hotel, 'ホテル', Colors.purple),
        const Divider(),
        ...List.generate(10, (index) => ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image, color: Colors.grey),
          ),
          title: Text('周辺の人気スポット $index'),
          subtitle: const Text('おすすめのレストラン・観光名所'),
          onTap: () {},
        )),
      ],
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildExploreCategory(IconData icon, String label, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(label),
      onTap: () {},
    );
  }
}
