import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/attendance');
              break;
            case 1:
              context.go('/leave');
              break;
            case 2:
              context.go('/profile');
              break;
          }
        },
        selectedIndex: _getSelectedIndex(context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fingerprint),
            label: 'Presensi',
          ),
          NavigationDestination(
            icon: Icon(Icons.beach_access),
            label: 'Cuti',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/attendance')) return 0;
    if (location.startsWith('/leave')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }
}