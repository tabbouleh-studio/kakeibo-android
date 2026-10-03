import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../entry/entry_screen.dart';
import '../home/home_screen.dart';
import '../ledger/ledger_screen.dart';
import '../reflection/reflection_screen.dart';
import '../settings/settings_screen.dart';

/// Bottom navigation: Home · Ledger · (+) · Reflect · Settings.
/// The centre button opens quick entry instead of switching tabs.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _addIndex = 2;

  // Tabs keep their state (scroll position, ledger month, search) while hidden.
  static const _tabs = [HomeScreen(), LedgerScreen(), ReflectionScreen(), SettingsScreen()];

  int _index = 0;

  void _select(int destination) {
    HapticFeedback.selectionClick();
    if (destination == _addIndex) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EntryScreen()));
      return;
    }
    setState(() => _index = destination);
  }

  int get _tab => _index > _addIndex ? _index - 1 : _index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PopScope(
      // Back from another tab returns to Home before leaving the app.
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _index = 0);
      },
      child: Scaffold(
        body: IndexedStack(index: _tab, children: _tabs),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.space_dashboard_outlined),
              selectedIcon: Icon(Icons.space_dashboard_rounded),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Ledger',
            ),
            NavigationDestination(
              icon: Container(
                width: 56,
                height: 32,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.add_rounded, color: scheme.onPrimary, size: 26),
              ),
              label: 'Add',
              tooltip: 'Add expense',
            ),
            const NavigationDestination(
              icon: Icon(Icons.self_improvement_outlined),
              selectedIcon: Icon(Icons.self_improvement_rounded),
              label: 'Reflect',
            ),
            const NavigationDestination(
              icon: Icon(Icons.tune_outlined),
              selectedIcon: Icon(Icons.tune_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
