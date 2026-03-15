import 'package:flutter/material.dart';

class UpdatesSheet extends StatelessWidget {
  const UpdatesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            const TabBar(
              tabs: [Tab(text: 'フォロー中'), Tab(text: '通知')],
              labelColor: Colors.blue,
              indicatorColor: Colors.blue,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFollowTab(),
                  _buildNotificationTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('フォロー中のビジネスからの最新情報', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildFeedItem(
          'スターバックス コーヒー',
          '新しい季節限定フラペチーノが登場しました！ぜひお試しください。',
          '3時間前',
        ),
        _buildFeedItem(
          '代々木公園',
          '今週末はフードフェスティバルが開催されます。',
          '1日前',
        ),
      ],
    );
  }

  Widget _buildNotificationTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('最近の通知', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const ListTile(
          leading: Icon(Icons.rate_review, color: Colors.blue),
          title: Text('あなたのクチコミが閲覧されました'),
          subtitle: Text('「東京駅」へのクチコミが100回閲覧されました。'),
          trailing: Text('2日前', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.local_offer, color: Colors.blue),
          title: Text('周辺のお得な情報'),
          subtitle: Text('近くのレストランで20%OFFのクーポンがあります。'),
          trailing: Text('5日前', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildFeedItem(String title, String content, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.store, color: Colors.white)),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(time),
            trailing: IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(content),
          ),
          Container(height: 150, color: Colors.grey[200], child: const Center(child: Icon(Icons.image, size: 48, color: Colors.grey))),
        ],
      ),
    );
  }
}
