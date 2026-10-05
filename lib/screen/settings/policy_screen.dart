import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/screen/settings/app_preferences.dart';
import 'package:arunstore/screen/settings/policy_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum StorePolicy {
  privacy('Privacy Policy', 'தனியுரிமைக் கொள்கை', Icons.privacy_tip_outlined),
  terms(
    'Terms & Conditions',
    'விதிமுறைகள் மற்றும் நிபந்தனைகள்',
    Icons.description_outlined,
  );

  const StorePolicy(this.title, this.tamilTitle, this.icon);
  final String title;
  final String tamilTitle;
  final IconData icon;

  String label(AppPreferences prefs) => prefs.text(title, tamilTitle);
}

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key, required this.policy});
  final StorePolicy policy;

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<AppPreferences>();
    final theme = Theme.of(context);
    final sections = policy == StorePolicy.privacy
        ? privacySections
        : termsSections;
    return Scaffold(
      appBar: AppBar(title: Text(policy.label(prefs))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: SizedBox(
                width: double.infinity,
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          policy.icon,
                          color: context.appForeground(theme.colorScheme.primary),
                          size: 40,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          policy.label(prefs),
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(prefs.text('Aroun Stores', 'அருண் ஸ்டோர்ஸ்')),
                        const SizedBox(height: 8),
                        Text(
                          prefs.text(
                            'Draft for review',
                            'மதிப்பாய்வுக்கான வரைவு',
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 24),
                        for (final section in sections) ...[
                          SelectableText(
                            prefs.text(section.$1, section.$3),
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            prefs.text(section.$2, section.$4),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
