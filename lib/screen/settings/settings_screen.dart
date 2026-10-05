import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/screen/settings/app_preferences.dart';
import 'package:arunstore/screen/settings/policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _save(BuildContext context, Future<void> operation) async {
    try {
      await operation;
    } catch (_) {
      if (!context.mounted) return;
      final prefs = context.read<AppPreferences>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            prefs.text(
              'Your choice is applied, but could not be saved for next time.',
              'உங்கள் தேர்வு பயன்படுத்தப்பட்டது. அடுத்த முறைக்காகச் சேமிக்க முடியவில்லை.',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<AppPreferences>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(prefs.text('Settings', 'அமைப்புகள்'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      prefs.text('Language', 'மொழி'),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      prefs.text(
                        'For all app screens',
                        'செயலியின் அனைத்துப் பக்கங்களுக்கும்',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('English')),
                        ButtonSegment(value: true, label: Text('தமிழ்')),
                      ],
                      selected: {prefs.isTamil},
                      onSelectionChanged: (selection) =>
                          _save(context, prefs.setLanguage(selection.single)),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      margin: EdgeInsets.zero,
                      child: SwitchListTile(
                        secondary: Icon(
                          prefs.isDark
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                        ),
                        title: Text(prefs.text('Dark theme', 'இருண்ட தோற்றம்')),
                        subtitle: Text(
                          prefs.isDark
                              ? prefs.text('Dark', 'இருண்டது')
                              : prefs.text('Light', 'வெளிச்சமானது'),
                        ),
                        value: prefs.isDark,
                        onChanged: (value) =>
                            _save(context, prefs.setDark(value)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      prefs.text('Legal', 'சட்டத் தகவல்கள்'),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (final policy in StorePolicy.values) ...[
                            if (policy != StorePolicy.values.first)
                              const Divider(height: 1),
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              leading: Icon(
                                policy.icon,
                                color: context.appForeground(theme.colorScheme.primary),
                              ),
                              title: Text(policy.label(prefs)),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => PolicyScreen(policy: policy),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
