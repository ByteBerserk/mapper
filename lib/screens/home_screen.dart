import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'overview_screen.dart';
import 'records_screen.dart';
import 'new_entry_screen.dart';
import '../providers/landmark_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const OverviewScreen(),
    const RecordsScreen(),
    const NewEntryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Refresh landmarks when switching to Overview or Records tab
          if (index == 0 || index == 1) {
            print('Switching to tab $index, refreshing landmarks...');
            context.read<LandmarkProvider>().fetchLandmarks();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Records',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_location_alt_outlined),
            selectedIcon: Icon(Icons.add_location_alt),
            label: 'New Entry',
          ),
        ],
      ),
    );
  }
}