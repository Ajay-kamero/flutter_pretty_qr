import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:flutter/painting.dart';

/// {@template pretty_qr_code.painting.PrettyQrDecorationImagePosition}
/// Where to paint a image decoration.
/// {@endtemplate}
enum PrettyQrDecorationImagePosition {
  /// Paint the image decoration inside the QR code.
  embedded,

  /// Paint the image decoration behind the QR code.
  background,

  /// Paint the image decoration in front of the QR code.
  foreground,
}

/// An image for a QR decoration.
@immutable
class PrettyQrDecorationImage extends DecorationImage {
  /// The padding for the QR image.
  @nonVirtual
  final EdgeInsetsGeometry padding;
  
  /// The border radius for the QR image.
  @nonVirtual
  final BorderRadius borderRadius;

  /// {@macro pretty_qr_code.painting.PrettyQrDecorationImagePosition}
  final PrettyQrDecorationImagePosition position;

  /// Creates an image to show into QR code.
  ///
  /// Not recommended to use scale over `0.2`, see the QR code
  /// [error correction](https://www.qrcode.com/en/about/error_correction.html) feature.
  @literal
  const PrettyQrDecorationImage({
    required super.image,
    super.scale = 0.2,
    super.onError,
    super.colorFilter,
    super.fit,
    super.repeat = ImageRepeat.noRepeat,
    super.matchTextDirection = false,
    super.opacity = 1.0,
    super.filterQuality = FilterQuality.low,
    super.invertColors = false,
    super.isAntiAlias = false,
    this.padding = EdgeInsets.zero,
    this.borderRadius = BorderRadius.zero,
    this.position = PrettyQrDecorationImagePosition.embedded,
  }) : assert(scale >= 0 && scale <= 1);
  
  /// Creates an image with rounded corners to show into QR code.
  /// 
  /// The [cornerRadius] parameter defines how much rounding to apply to the corners.
  /// For a circular image, use a radius that is half the image width/height.
  @factory
  static PrettyQrDecorationImage rounded({
    required ImageProvider image,
    double scale = 0.2,
    ImageErrorListener? onError,
    ColorFilter? colorFilter,
    BoxFit? fit,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    bool matchTextDirection = false,
    double opacity = 1.0,
    FilterQuality filterQuality = FilterQuality.low,
    bool invertColors = false,
    bool isAntiAlias = false,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    double cornerRadius = 8.0,
    PrettyQrDecorationImagePosition position = PrettyQrDecorationImagePosition.embedded,
  }) {
    return PrettyQrDecorationImage(
      image: image,
      scale: scale,
      onError: onError,
      colorFilter: colorFilter,
      fit: fit,
      repeat: repeat,
      matchTextDirection: matchTextDirection,
      opacity: opacity,
      filterQuality: filterQuality,
      invertColors: invertColors,
      isAntiAlias: isAntiAlias,
      padding: padding,
      borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
      position: position,
    );
  }

  /// Creates a copy of this [PrettyQrDecorationImage] but with the given fields
  /// replaced with the new values.
  @factory
  @useResult
  PrettyQrDecorationImage copyWith({
    final ImageProvider? image,
    final double? scale,
    final ImageErrorListener? onError,
    final ColorFilter? colorFilter,
    final BoxFit? fit,
    final ImageRepeat? repeat,
    final bool? matchTextDirection,
    final double? opacity,
    final FilterQuality? filterQuality,
    final bool? invertColors,
    final bool? isAntiAlias,
    final EdgeInsetsGeometry? padding,
    final BorderRadius? borderRadius,
    final PrettyQrDecorationImagePosition? position,
  }) {
    return PrettyQrDecorationImage(
      image: image ?? this.image,
      scale: scale ?? this.scale,
      onError: onError ?? this.onError,
      colorFilter: colorFilter ?? this.colorFilter,
      fit: fit ?? this.fit,
      repeat: repeat ?? this.repeat,
      matchTextDirection: matchTextDirection ?? this.matchTextDirection,
      opacity: opacity ?? this.opacity,
      filterQuality: filterQuality ?? this.filterQuality,
      invertColors: invertColors ?? this.invertColors,
      isAntiAlias: isAntiAlias ?? this.isAntiAlias,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      position: position ?? this.position,
    );
  }

  /// Linearly interpolates between two [PrettyQrDecorationImage]s.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static PrettyQrDecorationImage? lerp(
    final PrettyQrDecorationImage? a,
    final PrettyQrDecorationImage? b,
    final double t,
  ) {
    if (identical(a, b)) {
      return a;
    }

    if (a != null && b != null) {
      if (t == 0.0) return a;
      if (t == 1.0) return b;
    }

    if (a == null) {
      return b?.copyWith(
        scale: b.scale * t,
        opacity: b.opacity * t,
        padding: EdgeInsetsGeometry.lerp(null, b.padding, t)!,
        borderRadius: BorderRadius.lerp(BorderRadius.zero, b.borderRadius, t),
      );
    }

    if (b == null) {
      return a.copyWith(
        scale: a.scale * (1.0 - t),
        opacity: a.opacity * (1.0 - t),
        padding: EdgeInsetsGeometry.lerp(a.padding, null, t)!,
        borderRadius: BorderRadius.lerp(a.borderRadius, BorderRadius.zero, t),
      );
    }

    return (t < 0.5 ? a : b).copyWith(
      scale: lerpDouble(a.scale, b.scale, t)!,
      opacity: lerpDouble(a.opacity, b.opacity, t)!,
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t)!,
      borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t),
    );
  }

  @override
  int get hashCode {
    return super.hashCode ^ Object.hash(runtimeType, padding, borderRadius);
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is PrettyQrDecorationImage &&
        super == other &&
        other.padding == padding &&
        other.borderRadius == borderRadius &&
        other.position == position;
  }
}
