import 'package:arunstore/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum StorePolicy {
  privacy('Privacy Policy', Icons.privacy_tip_outlined),
  terms('Terms & Conditions', Icons.description_outlined);

  const StorePolicy(this.title, this.icon);

  final String title;
  final IconData icon;
}

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key, required this.policy});

  final StorePolicy policy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(policy.title)),
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
                        Icon(policy.icon, color: AppColors.primary, size: 40),
                        const SizedBox(height: 20),
                        Text(policy.title, style: AppTextStyles.headingLarge),
                        const SizedBox(height: 8),
                        const Text(
                          'Aroun Stores',
                          style: TextStyle(color: AppColors.mutedText),
                        ),
                        const SizedBox(height: 24),
                        // Replace this placeholder with the approved policy text.
                        const SelectableText(
                          'Content coming soon',
                          style: AppTextStyles.headingMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          policy == StorePolicy.privacy
                              ? 'The Privacy Policy has not been published yet. '
                                    'Please check back later.'
                              : 'The Terms & Conditions have not been published '
                                    'yet. Please check back later.',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.mediumText,
                          ),
                        ),
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
