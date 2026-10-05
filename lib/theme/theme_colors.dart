import 'package:flutter/material.dart';

/// Adapts existing brand colors by their role without filtering product images.
/// Light mode retains the original palette.
extension AppThemeColors on BuildContext {
  Color appBackground(Color? light) => Theme.of(this).brightness == Brightness.dark
      ? Theme.of(this).scaffoldBackgroundColor
      : light ?? Theme.of(this).scaffoldBackgroundColor;

  Color appSurface(Color? light) {
    final theme = Theme.of(this);
    final color = light ?? theme.colorScheme.surface;
    if (theme.brightness != Brightness.dark || color.a < 0.5) return color;
    final hsl = HSLColor.fromColor(color);
    if (hsl.lightness < 0.65) return color; // Solid brand fills and photo overlays.
    final neutral = hsl.saturation < 0.16;
    final surface = neutral
        ? (hsl.lightness > 0.94
            ? theme.colorScheme.surface
            : theme.colorScheme.surfaceContainerHigh)
        : Color.lerp(theme.colorScheme.surface, color, 0.12)!;
    return surface.withValues(alpha: color.a);
  }

  Color appForeground(Color? light) {
    final theme = Theme.of(this);
    final color = light ?? theme.colorScheme.onSurface;
    if (theme.brightness != Brightness.dark || color.a == 0) return color;
    final hsl = HSLColor.fromColor(color);
    if (hsl.lightness > 0.88) return color; // White on brand fills stays white.
    const neutralInk = {
      0xFF0F172A, 0xFF1E293B, 0xFF111827, 0xFF1F2937, 0xFF334155,
      0xFF374151, 0xFF475569, 0xFF4B5563, 0xFF64748B, 0xFF6B7280,
      0xFF94A3B8, 0xFF9CA3AF,
    };
    if (hsl.saturation < 0.16 || neutralInk.contains(color.withValues(alpha: 1).toARGB32())) {
      final ink = hsl.lightness < 0.3
          ? theme.colorScheme.onSurface
          : theme.colorScheme.onSurfaceVariant;
      return ink.withValues(alpha: color.a);
    }
    return hsl.withLightness(hsl.lightness.clamp(0.72, 1.0))
        .withSaturation(hsl.saturation.clamp(0.0, 0.75))
        .toColor();
  }

  Color appBorder(Color? light) {
    final theme = Theme.of(this);
    final color = light ?? theme.colorScheme.outlineVariant;
    if (theme.brightness != Brightness.dark || color.a == 0) return color;
    if (HSLColor.fromColor(color).saturation < 0.2) {
      return theme.colorScheme.outlineVariant.withValues(alpha: color.a);
    }
    return appForeground(color);
  }

  List<Color> appGradient(List<Color> colors) => colors.map(appSurface).toList();
}
