import 'package:arunstore/l10n/tamil_messages.dart';
import 'package:arunstore/screen/settings/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

String _normalize(String value) =>
    value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
final _messages = {
  for (final entry in tamilMessages.entries) _normalize(entry.key): entry.value,
};

// Placeholders preserve server-provided names, amounts, IDs, and other values.
const _templates = <String, String>{
  '{0} Aroun Stores. All rights reserved.':
      '{0} அருண் ஸ்டோர்ஸ். அனைத்து உரிமைகளும் பாதுகாக்கப்பட்டவை.',
  '{0} products found': '{0} பொருட்கள் கிடைத்தன',
  '{0} products': '{0} பொருட்கள்',
  '{0} product': '{0} பொருள்',
  '{0} items available': '{0} பொருட்கள் இருப்பில் உள்ளன',
  '{0} items': '{0} பொருட்கள்',
  '{0} is already in cart': '{0} ஏற்கனவே கூடையில் உள்ளது',
  'Added {0} to cart': '{0} கூடையில் சேர்க்கப்பட்டது',
  'In Cart ({0})': 'கூடையில் ({0})',
  'Qty {0}': 'அளவு {0}',
  'From {0}': '{0} முதல்',
  'Pay now - {0}': 'இப்போது செலுத்தவும் - {0}',
  'Order ID: {0}': 'ஆர்டர் எண்: {0}',
  'Payment ID: {0}': 'பணப்பரிவர்த்தனை எண்: {0}',
  'Placed on: {0}': 'ஆர்டர் செய்த நாள்: {0}',
  'Category: {0}': 'வகை: {0}',
  'Categories: {0}': 'வகைகள்: {0}',
  'Stock: {0}': 'இருப்பு: {0}',
  '{0}% OFF': '{0}% தள்ளுபடி',
  'Save {0}%': '{0}% சேமிப்பு',
  'There are no products in {0}': '{0} வகையில் பொருட்கள் இல்லை',
  '{0} - Coming Soon!': '{0} - விரைவில் வருகிறது!',
  'Image {0}': 'படம் {0}',
  'Img {0}': 'படம் {0}',
  'External wallet selected: {0}.':
      'வெளிப்புற வாலட் தேர்ந்தெடுக்கப்பட்டது: {0}.',
  'Thank you! "{0}" has been subscribed to our newsletter.':
      'நன்றி! "{0}" எங்கள் செய்திமடலுக்குச் சந்தா சேர்ந்துள்ளது.',
  'Failed to load products: {0}': 'பொருட்களை ஏற்ற முடியவில்லை: {0}',
  'Failed to delete: {0}': 'நீக்க முடியவில்லை: {0}',
  'Failed to pick image: {0}': 'படத்தைத் தேர்ந்தெடுக்க முடியவில்லை: {0}',
  'Error saving product: {0}': 'பொருளைச் சேமிப்பதில் பிழை: {0}',
  'Error: {0}': 'பிழை: {0}',
  'Network error: {0}': 'இணையப் பிழை: {0}',
  'Login error: {0}': 'உள்நுழைவுப் பிழை: {0}',
  'Login failed. Status code: {0}':
      'உள்நுழைய முடியவில்லை. நிலைக் குறியீடு: {0}',
  'Registration failed. Status code: {0}':
      'பதிவு செய்ய முடியவில்லை. நிலைக் குறியீடு: {0}',
  'Registration failed! {0}': 'பதிவு செய்ய முடியவில்லை! {0}',
};
final _patterns = [
  for (final entry in _templates.entries)
    (
      RegExp(
        '^${entry.key.split('{0}').map(RegExp.escape).join('(.*?)')}\$',
        dotAll: true,
      ),
      entry.value,
    ),
];

String translate(String value, {required bool tamil}) {
  if (!tamil) return value;
  final message = _messages[_normalize(value)];
  if (message != null) return message;
  if (value.endsWith(' is required.')) {
    final field = value.substring(0, value.length - ' is required.'.length);
    return '${translate(field, tamil: true)} கட்டாயம்.';
  }
  const statuses = {
    'Payment failed': 'பணப்பரிவர்த்தனை தோல்வியடைந்தது',
    'Payment pending': 'பணப்பரிவர்த்தனை நிலுவையில் உள்ளது',
    'Payment cancelled': 'பணப்பரிவர்த்தனை ரத்து செய்யப்பட்டது',
    'Payment canceled': 'பணப்பரிவர்த்தனை ரத்து செய்யப்பட்டது',
    'Payment success': 'பணப்பரிவர்த்தனை வெற்றி',
    'Payment paid': 'பணம் செலுத்தப்பட்டது',
  };
  if (statuses.containsKey(value)) return statuses[value]!;
  for (final (pattern, template) in _patterns) {
    final match = pattern.firstMatch(value);
    if (match != null) return template.replaceAll('{0}', match.group(1)!);
  }
  return value;
}

extension AppTranslation on BuildContext {
  String tr(String value) =>
      translate(value, tamil: watch<AppPreferences?>()?.isTamil ?? false);
}

/// Translates UI copy at render time so open routes and dialogs update in place.
/// Use Flutter's Text for product names and other unmodified user/server content.
class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) => Text(
    context.tr(data),
    style: style,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );
}

extension LocalizedInputDecoration on InputDecoration {
  InputDecoration localized(BuildContext context) => copyWith(
    labelText: labelText == null ? null : context.tr(labelText!),
    hintText: hintText == null ? null : context.tr(hintText!),
    helperText: helperText == null ? null : context.tr(helperText!),
    errorText: errorText == null ? null : context.tr(errorText!),
    prefixText: prefixText == null ? null : context.tr(prefixText!),
    suffixText: suffixText == null ? null : context.tr(suffixText!),
    counterText: counterText == null ? null : context.tr(counterText!),
  );
}

Widget localizedFormError(BuildContext context, String error) => AppText(
  error,
  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
);

/// Preserves user/server text and translates only an app-owned empty-state label.
class AppDataText extends AppText {
  const AppDataText(
    String? value, {
    required this.fallback,
    super.key,
    super.style,
    super.textAlign,
    super.maxLines,
    super.overflow,
  }) : hasValue = value != null,
       super(value ?? '');

  final String fallback;
  final bool hasValue;

  @override
  Widget build(BuildContext context) => Text(
    hasValue ? data : context.tr(fallback),
    style: style,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );
}
