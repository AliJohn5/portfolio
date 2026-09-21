import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:portfolio/src/common/domain/icon.dart';

class MyIcon extends ConsumerWidget {
  const MyIcon({
    super.key,
    this.icon,
    this.placeholder = const SizedBox.shrink(),
    this.size = 24,
    this.padding,
  });

  final IconModel? icon;
  final double? size;
  final Widget placeholder;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconAssetName = icon?.assetName;
    final iconCodePoint = icon?.codePoint;
    final iconFontFamily = icon?.fontFamily;
    final iconColor = icon?.color;

    Color? color;

    if (iconColor != null) {
      final colorHex = int.tryParse(iconColor);

      if (colorHex != null) {
        color = Color(colorHex);
      }
    }

    // Font icon
    if (iconCodePoint != null && iconFontFamily != null) {
      final codePoint = int.tryParse(iconCodePoint);

      if (codePoint != null) {
        final iconData = IconData(
          codePoint,
          fontFamily: iconFontFamily,
        );

        return Padding(
          padding: padding ?? EdgeInsets.zero,
          child: FittedBox(
            child: Icon(
              iconData,
              color: color,
              size: size,
            ),
          ),
        );
      }
    }

    // SVG icon
    if (iconAssetName != null) {
      return Padding(
        padding: padding ?? EdgeInsets.zero,
        child: SvgPicture.asset(
          iconAssetName,
          width: size,
          height: size,
          colorFilter: color == null
              ? null
              : ColorFilter.mode(
                  color,
                  BlendMode.srcIn,
                ),
        ),
      );
    }

    return placeholder;
  }
}