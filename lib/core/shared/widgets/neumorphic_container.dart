import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isInner;
  final Color? color;
  final BoxShape shape;
  final double depth;

  const NeumorphicContainer({
    Key? key,
    this.child,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.padding,
    this.margin,
    this.isInner = false,
    this.color,
    this.shape = BoxShape.rectangle,
    this.depth = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? AppColors.bg;

    if (isInner) {
      return Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
          shape: shape,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark.withOpacity(0.5),
              offset: Offset(depth / 2, depth / 2),
              blurRadius: depth,
            ),
            BoxShadow(
              color: AppColors.shadowLight,
              offset: Offset(-depth / 2, -depth / 2),
              blurRadius: depth,
            ),
          ],
        ),
        // For true inner shadow, we would use a custom painter, but to keep it 
        // simple and avoiding extra dependencies, we will wrap it and use an inset approach or
        // a gradient illusion for inner depth.
        // But since standard Container doesn't do inner shadow well, let's use a BoxDecoration trick.
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
            shape: shape,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.shadowDark.withOpacity(0.2),
                AppColors.shadowLight.withOpacity(0.5),
              ],
            ),
          ),
          child: child,
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
        shape: shape,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withOpacity(0.5),
            offset: Offset(depth / 2, depth / 2),
            blurRadius: depth,
          ),
          BoxShadow(
            color: AppColors.shadowLight,
            offset: Offset(-depth / 2, -depth / 2),
            blurRadius: depth,
          ),
        ],
      ),
      child: child,
    );
  }
}
