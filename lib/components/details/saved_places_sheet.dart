import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/map_provider.dart';

class SavedPlacesSheet extends StatelessWidget {
  const SavedPlacesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    final favorites = mapProvider.favorites;

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('保存済みの場所', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          if (favorites.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('まだ保存された場所はありません', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: favorites.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final place = favorites[index];
                  return ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.location_on, color: Colors.white)),
                    title: Text(place.name),
                    subtitle: Text(place.category),
                    onTap: () {
                      mapProvider.selectPlace(place);
                      // TODO: MapScreen側でタブを「探索」に戻す処理が必要
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
