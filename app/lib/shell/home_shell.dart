import 'package:flutter/material.dart';

import '../features/charts/charts_screen.dart';
import '../features/history/history_screen.dart';
import '../features/more/more_screen.dart';
import '../features/today/today_screen.dart';

/// The five bottom tabs (SPEC section 7). Progress (photos) is the only tab not built yet.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = [
    (label: 'Today', icon: Icons.today_outlined, selected: Icons.today),
    (label: 'History', icon: Icons.list_alt_outlined, selected: Icons.list_alt),
    (label: 'Progress', icon: Icons.photo_camera_outlined, selected: Icons.photo_camera),
    (label: 'Charts', icon: Icons.show_chart, selected: Icons.show_chart),
    (label: 'More', icon: Icons.more_horiz, selected: Icons.more_horiz),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const TodayScreen(),
          const HistoryScreen(),
          _ComingSoon(title: _tabs[2].label),
          const ChartsScreen(),
          const MoreScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(icon: Icon(tab.icon), selectedIcon: Icon(tab.selected), label: tab.label),
        ],
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('Not built yet.', style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant)),
      ),
    );
  }
}
