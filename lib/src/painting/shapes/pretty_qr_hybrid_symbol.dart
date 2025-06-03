import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:flutter/painting.dart';

import 'package:pretty_qr_code/src/painting/pretty_qr_brush.dart';
import 'package:pretty_qr_code/src/painting/pretty_qr_shape.dart';
import 'package:pretty_qr_code/src/base/pretty_qr_neighbour_direction.dart';
import 'package:pretty_qr_code/src/rendering/pretty_qr_painting_context.dart';
import 'package:pretty_qr_code/src/rendering/pretty_qr_render_capabilities.dart';
import 'package:pretty_qr_code/src/painting/extensions/pretty_qr_module_extensions.dart';
import 'package:pretty_qr_code/src/base/extensions/pretty_qr_neighbour_direction_extensions.dart';

/// A hybrid QR code symbol that combines smooth styling for the outer part of finder patterns
/// with rounded styling for the inner part of finder patterns and other modules.
@sealed
class PrettyQrHybridSymbol extends PrettyQrShape {
  /// The color or brush to use when filling the QR code.
  @nonVirtual
  final Color color;

  /// If non-null, the corners of regular QR modules are rounded by this [BorderRadius].
  @nonVirtual
  final BorderRadiusGeometry borderRadius;

  /// The smooth factor for the outer squares of finder patterns (corner squares).
  /// Controls the rounding of outer corners in finder patterns.
  /// The inner squares will always use the rounded style regardless of this value.
  /// Values greater than 1.0 create super-rounded corners.
  @nonVirtual
  final double smoothFactor;
  
  /// Controls how pronounced the inner corners of finder patterns appear.
  /// Higher values create more noticeable inner corners.
  @nonVirtual
  final double innerCornerFactor;

  /// The default value for [borderRadius].
  static const kDefaultBorderRadius = BorderRadius.all(
    Radius.circular(8),
  );

  /// Creates a hybrid QR shape that combines smooth finder patterns with rounded modules.
  @literal
  const PrettyQrHybridSymbol({
    this.color = const Color(0xFF000000),
    this.borderRadius = kDefaultBorderRadius,
    this.smoothFactor = 1,
    this.innerCornerFactor = 1,
  }) : assert(smoothFactor >= 0, 'smoothFactor must be greater than or equal to 0'),
       assert(innerCornerFactor <= 1.5, 'innerCornerFactor must be less than or equal to 1.5'),
       assert(innerCornerFactor >= 0, 'innerCornerFactor must be greater than or equal to 0');

  @override
  void paint(PrettyQrPaintingContext context) {
    final path = Path();
    final brush = PrettyQrBrush.from(color);

    final paint = brush.toPaint(
      context.estimatedBounds,
      textDirection: context.textDirection,
    );

    final radius = borderRadius.resolve(context.textDirection);

    for (final module in context.matrix) {
      final moduleRect = module.resolveRect(context);
      final moduleNeighbours = context.matrix.getNeighboursDirections(module);
      
      Path modulePath;
      
      // Check if this module is part of a finder pattern (one of the three corner squares)
      if (context.matrix.isFinderPatternPoint(module)) {
        if (module.isDark) {
          // Check if this is part of the inner 3x3 square of the finder pattern
          if (context.matrix.isInnerFinderPatternPoint(module)) {
            // Use rounded style for inner finder pattern dark modules
            modulePath = Path();
            modulePath
              ..addRRect(radius.toRRect(moduleRect))
              ..close();
          } else {
            // Use smooth style for outer finder pattern dark modules
            modulePath = Path();
            modulePath
              ..addRRect(transformSmoothModuleRect(moduleRect, moduleNeighbours))
              ..close();
          }
        } else {
          // Handle white modules in finder patterns with inner corner rounding
          modulePath = transformWhiteModuleRect(moduleRect, moduleNeighbours);
        }
      } else if (module.isDark) {
        // Use rounded style for all other dark modules
        modulePath = Path();
        modulePath
          ..addRRect(radius.toRRect(moduleRect))
          ..close();
      } else {
        // Skip non-dark modules that aren't part of finder patterns
        continue;
      }

      if (PrettyQrRenderCapabilities.needsAvoidComplexPaths) {
        context.canvas.drawPath(modulePath, paint);
      } else {
        path.addPath(modulePath, Offset.zero);
      }
    }

    path.close();
    context.canvas.drawPath(path, paint);
  }

  /// Transforms the module rectangle for smooth styling (used for finder patterns)
  /// This applies extreme rounded corners to the outer squares of finder patterns
  @protected
  @pragma('vm:prefer-inline')
  RRect transformSmoothModuleRect(
    final Rect moduleRect,
    final Set<PrettyQrNeighbourDirection> neighbours,
  ) {
    // Enhanced corner radius for finder patterns
    // Using an extremely large radius to create super rounded corners
    // The multiplier 2.0 means the radius is twice the module size
    final cornersRadius = Radius.circular(
      moduleRect.shortestSide * 4.0 * smoothFactor.clamp(0.0, 1.0),
    );

    if (!neighbours.hasClosest) {
      return RRect.fromRectAndRadius(moduleRect, cornersRadius);
    }

    return RRect.fromRectAndCorners(
      moduleRect,
      topLeft: neighbours.atTopOrLeft ? Radius.zero : cornersRadius,
      topRight: neighbours.atTopOrRight ? Radius.zero : cornersRadius,
      bottomLeft: neighbours.atBottomOrLeft ? Radius.zero : cornersRadius,
      bottomRight: neighbours.atBottomOrRight ? Radius.zero : cornersRadius,
    );
  }
  
  /// Transforms white module rectangles to create smooth inner corners
  /// This is specifically for the white spaces in finder patterns
  @protected
  @pragma('vm:prefer-inline')
  Path transformWhiteModuleRect(
    final Rect moduleRect,
    final Set<PrettyQrNeighbourDirection> neighbours,
  ) {
    final path = Path();
    // Use innerCornerFactor to control the size of inner corners
    final padding = (smoothFactor / 2 * innerCornerFactor).clamp(0.0, 0.5) * moduleRect.longestSide;

    // Add inner corners where needed based on neighboring dark modules
    if (neighbours.atTopAndLeft && neighbours.atToptLeft) {
      path.addPath(
        buildInnerCornerShape(
          moduleRect.topLeft.translate(0, padding),
          moduleRect.topLeft,
          moduleRect.topLeft.translate(padding, 0),
        ),
        Offset.zero,
      );
    }

    if (neighbours.atTopAndRight && neighbours.atToptRight) {
      path.addPath(
        buildInnerCornerShape(
          moduleRect.topRight.translate(-padding, 0),
          moduleRect.topRight,
          moduleRect.topRight.translate(0, padding),
        ),
        Offset.zero,
      );
    }

    if (neighbours.atBottomAndLeft && neighbours.atBottomLeft) {
      path.addPath(
        buildInnerCornerShape(
          moduleRect.bottomLeft.translate(0, -padding),
          moduleRect.bottomLeft,
          moduleRect.bottomLeft.translate(padding, 0),
        ),
        Offset.zero,
      );
    }

    if (neighbours.atBottomAndRight && neighbours.atBottomRight) {
      path.addPath(
        buildInnerCornerShape(
          moduleRect.bottomRight.translate(-padding, 0),
          moduleRect.bottomRight,
          moduleRect.bottomRight.translate(0, -padding),
        ),
        Offset.zero,
      );
    }

    return path..close();
  }
  
  /// Builds an inner corner shape for smooth transitions
  @protected
  @pragma('vm:prefer-inline')
  Path buildInnerCornerShape(
    Offset firstPoint,
    Offset centerPoint,
    Offset lastPoint,
  ) {
    return Path()
      ..moveTo(firstPoint.dx, firstPoint.dy)
      ..quadraticBezierTo(
        centerPoint.dx,
        centerPoint.dy,
        lastPoint.dx,
        lastPoint.dy,
      )
      ..lineTo(centerPoint.dx, centerPoint.dy)
      ..lineTo(firstPoint.dx, firstPoint.dy)
      ..close();
  }

  @override
  PrettyQrHybridSymbol? lerpFrom(PrettyQrShape? a, double t) {
    if (identical(a, this)) {
      return this;
    }

    if (a == null) return this;
    if (a is! PrettyQrHybridSymbol) return null;

    if (t == 0.0) return a;
    if (t == 1.0) return this;

    return PrettyQrHybridSymbol(
      color: PrettyQrBrush.lerp(a.color, color, t)!,
      borderRadius: BorderRadiusGeometry.lerp(a.borderRadius, borderRadius, t)!,
      smoothFactor: lerpDouble(a.smoothFactor, smoothFactor, t)!,
      innerCornerFactor: lerpDouble(a.innerCornerFactor, innerCornerFactor, t)!,
    );
  }

  @override
  PrettyQrHybridSymbol? lerpTo(PrettyQrShape? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    if (b == null) return this;
    if (b is! PrettyQrHybridSymbol) return null;

    if (t == 0.0) return this;
    if (t == 1.0) return b;

    return PrettyQrHybridSymbol(
      color: PrettyQrBrush.lerp(color, b.color, t)!,
      borderRadius: BorderRadiusGeometry.lerp(borderRadius, b.borderRadius, t)!,
      smoothFactor: lerpDouble(smoothFactor, b.smoothFactor, t)!,
      innerCornerFactor: lerpDouble(innerCornerFactor, b.innerCornerFactor, t)!,
    );
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, color, borderRadius, smoothFactor, innerCornerFactor);
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is PrettyQrHybridSymbol &&
        other.color == color &&
        other.borderRadius == borderRadius &&
        other.smoothFactor == smoothFactor &&
        other.innerCornerFactor == innerCornerFactor;
  }
}
