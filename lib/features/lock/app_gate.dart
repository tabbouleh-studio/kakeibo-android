import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../data/providers.dart';
import '../../util/period.dart';

final localAuthProvider = Provider((ref) => LocalAuthentication());

/// Lets the app show snackbars from outside any screen.
final messengerKey = GlobalKey<ScaffoldMessengerState>();

/// Locks the app after this long in the background.
const lockAfter = Duration(minutes: 1);

/// Asks the phone's own biometric/PIN/pattern prompt. Returns whether the
/// user got through, or throws [LocalAuthException].
Future<bool> authenticate(WidgetRef ref, String reason) => ref
    .read(localAuthProvider)
    .authenticate(localizedReason: reason, persistAcrossBackgrounding: true);

/// Runs work when the app opens or returns to the foreground: logs due
/// recurring entries, rolls over to a new day, and applies the app lock.
class AppGate extends ConsumerStatefulWidget {
  const AppGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppGate> createState() => _AppGateState();
}

class _AppGateState extends ConsumerState<AppGate> with WidgetsBindingObserver {
  late bool _locked;
  bool _authenticating = false;
  DateTime? _backgroundedAt;
  DateTime _day = dateOnly(DateTime.now());
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _locked = ref.read(settingsProvider).lockEnabled;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processRecurring();
      if (_locked) _unlock();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The system PIN screen also sends the app to the background; ignore it.
    if (_authenticating) return;
    switch (state) {
      case AppLifecycleState.hidden || AppLifecycleState.paused:
        _backgroundedAt ??= DateTime.now();
      case AppLifecycleState.resumed:
        final away = _backgroundedAt == null
            ? Duration.zero
            : DateTime.now().difference(_backgroundedAt!);
        _backgroundedAt = null;
        final today = dateOnly(DateTime.now());
        if (today != _day) {
          _day = today;
          ref.invalidate(currentPeriodProvider);
        }
        _processRecurring();
        if (ref.read(settingsProvider).lockEnabled && away >= lockAfter && !_locked) {
          setState(() => _locked = true);
          _unlock();
        }
      default:
        break;
    }
  }

  Future<void> _processRecurring() async {
    final added = await ref.read(databaseProvider).processDueRecurring(dateOnly(DateTime.now()));
    if (added > 0) {
      messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Added $added recurring ${added == 1 ? 'expense' : 'expenses'}')),
      );
    }
  }

  Future<void> _unlock() async {
    if (_authenticating) return;
    setState(() {
      _authenticating = true;
      _error = null;
    });
    try {
      final ok = await authenticate(ref, 'Unlock Kakeibo');
      if (ok && mounted) setState(() => _locked = false);
    } on LocalAuthException catch (e) {
      if (e.code == LocalAuthExceptionCode.noCredentialsSet ||
          e.code == LocalAuthExceptionCode.noBiometricHardware) {
        // The phone no longer has a screen lock, so the app can't be locked.
        await ref.read(settingsProvider.notifier).setLockEnabled(false);
        if (mounted) setState(() => _locked = false);
        messengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('App lock turned off: this phone has no screen lock set up.'),
          ),
        );
      } else if (e.code != LocalAuthExceptionCode.userCanceled &&
          e.code != LocalAuthExceptionCode.systemCanceled) {
        if (mounted) setState(() => _error = e.description ?? 'Could not unlock. Try again.');
      }
    } finally {
      if (mounted) setState(() => _authenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_locked) _LockScreen(onUnlock: _unlock, busy: _authenticating, error: _error),
      ],
    );
  }
}

class _LockScreen extends StatelessWidget {
  const _LockScreen({required this.onUnlock, required this.busy, this.error});

  final VoidCallback onUnlock;
  final bool busy;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned.fill(
      child: Material(
        color: theme.colorScheme.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(flex: 3),
                Text('家計簿', style: theme.textTheme.displaySmall),
                const SizedBox(height: 8),
                Text('Kakeibo is locked', style: theme.textTheme.titleMedium),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                  ),
                ],
                const Spacer(flex: 4),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: busy ? null : onUnlock,
                    icon: const Icon(Icons.fingerprint_rounded),
                    label: const Text('Unlock'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
