import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          const _SettingsHeader(title: 'アカウント'),
          const ListTile(
            leading: CircleAvatar(child: Text('R')),
            title: Text('Tanaka Riku'),
            subtitle: Text('localguide-level4@example.com'),
            trailing: Icon(Icons.chevron_right),
          ),
          const Divider(),
          const _SettingsHeader(title: '地図の設定'),
          SwitchListTile(
            title: const Text('交通状況レイヤーを常に表示'),
            value: mapProvider.trafficEnabled,
            onChanged: (_) => mapProvider.toggleTraffic(),
          ),
          ListTile(
            title: const Text('距離の単位'),
            subtitle: const Text('自動'),
            onTap: () {},
          ),
          const Divider(),
          const _SettingsHeader(title: 'プライバシー'),
          ListTile(
            title: const Text('ロケーション履歴'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('オフラインマップの設定'),
            onTap: () {},
          ),
          const Divider(),
          const _SettingsHeader(title: 'アプリ情報'),
          const ListTile(title: Text('バージョン'), subtitle: Text('1.0.0 (Build 2024.04)')),
        ],
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final String title;
  const _SettingsHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}
