import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_info.dart';
import '../../theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _copy(BuildContext context, String text, String what) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text('$what copied')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = KakeiboColors.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      height: 1.4,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: colors.hero, shape: BoxShape.circle),
              child: Icon(Icons.menu_book_rounded, size: 38, color: colors.onHero),
            ),
          ),
          const SizedBox(height: 16),
          Text(appName, textAlign: TextAlign.center, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text('Version $appVersion', textAlign: TextAlign.center, style: muted),
          const SizedBox(height: 12),
          Text(
            'Mindful budgeting based on the Japanese kakeibo method.',
            textAlign: TextAlign.center,
            style: muted,
          ),
          const SizedBox(height: 24),
          _Section(
            icon: Icons.lock_outline_rounded,
            title: 'Your privacy',
            child: Text(
              'Kakeibo works fully offline and does not even have permission to use the '
              'internet. There is no account, no ads, no analytics and no tracking. '
              'Everything you enter stays on this phone. Backups are plain files that '
              'you save and keep yourself.',
              style: muted,
            ),
          ),
          const SizedBox(height: 12),
          _Section(
            icon: Icons.code_rounded,
            title: 'Free and open source',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kakeibo is free software, licensed under the $appLicense. '
                  'You can read, change and share the source code.',
                  style: muted,
                ),
                const SizedBox(height: 12),
                _CopyRow(
                  text: sourceCodeUrl.replaceFirst('https://', ''),
                  onCopy: () => _copy(context, sourceCodeUrl, 'Link'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: Icon(Icons.description_outlined, color: theme.colorScheme.primary),
              title: const Text('Open-source licenses'),
              subtitle: const Text('Libraries Kakeibo is built with'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => showLicensePage(
                context: context,
                applicationName: appName,
                applicationVersion: appVersion,
                applicationLegalese: '© $studioName · $appLicense',
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Made with ❤️ by $studioName 🥗',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.child});

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(title, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _CopyRow extends StatelessWidget {
  const _CopyRow({required this.text, required this.onCopy});

  final String text;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onCopy,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.copy_rounded, size: 18, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
