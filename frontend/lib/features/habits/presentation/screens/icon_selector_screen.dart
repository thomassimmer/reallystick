import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IconSelectorScreen extends StatelessWidget {
  final Function(IconData) onIconSelected;

  IconSelectorScreen({required this.onIconSelected});

  // List of Material icons (partial list; extend as needed)
  final Map<String, IconData> materialIcons = {
    'home': Icons.home,
    'favorite': Icons.favorite,
    'search': Icons.search,
    'settings': Icons.settings,
    'star': Icons.star,
    'person': Icons.person,
    'alarm': Icons.alarm,
    'camera': Icons.camera,
    'email': Icons.email,
    'phone': Icons.phone,
    // Add more icons as needed
  };


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.selectIcon),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
        itemCount: materialIcons.length,
        itemBuilder: (context, index) {
          final iconName = materialIcons.keys.elementAt(index);
          final iconData = materialIcons[iconName]!;

          return GestureDetector(
            onTap: () {
              onIconSelected(iconData);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconData, size: 36.0),
                SizedBox(height: 4.0),
                Text(
                  iconName,
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
