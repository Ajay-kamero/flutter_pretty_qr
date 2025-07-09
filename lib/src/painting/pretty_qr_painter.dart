import 'package:meta/meta.dart';
import 'package:flutter/painting.dart';

import 'package:pretty_qr_code/src/rendering/pretty_qr_painting_context.dart';

import 'package:pretty_qr_code/src/painting/pretty_qr_brush.dart';

import 'package:pretty_qr_code/src/painting/decoration/pretty_qr_decoration.dart';
import 'package:pretty_qr_code/src/painting/decoration/pretty_qr_decoration_image.dart';

import 'package:pretty_qr_code/src/painting/extensions/pretty_qr_module_extensions.dart';
import 'package:pretty_qr_code/src/painting/extensions/pretty_qr_quiet_zone_extension.dart';

/// A stateful class that can paint a QR code.
///
/// To obtain a painter, call [PrettyQrDecoration.createPainter].
@internal
class PrettyQrPainter {
  /// Callback that is invoked if an asynchronously-loading resource used by the
  /// decoration finishes loading. For example, an image. When this is invoked,
  /// the [paint] method should be called again.
  @nonVirtual
  final VoidCallback onChanged;

  /// What decoration to paint.
  @nonVirtual
  final PrettyQrDecoration decoration;

  /// The painter for a [PrettyQrDecorationImage].
  @protected
  DecorationImagePainter? _decorationImagePainter;
  
  /// The painter for the fallback image if the primary image fails.
  @protected  
  DecorationImagePainter? _fallbackImagePainter;
  
  /// Cached aspect ratio of the loaded image
  @protected
  double? _imageAspectRatio;
  
  /// Flag to track if we've attempted to resolve the image
  @protected
  bool _imageResolutionAttempted = false;
  
  /// Flag to track if the primary image failed and we should use fallback
  @protected
  bool _useFallbackImage = false;

  /// Creates a QR code painter.
  PrettyQrPainter({
    required this.onChanged,
    required this.decoration,
  });

  /// Draw the QR code image onto the given canvas.
  @nonVirtual
  void paint(
    final PrettyQrPaintingContext context,
    final ImageConfiguration configuration,
  ) {
    final background = decoration.background;
    if (background != null) {
      final backgroundBrush = PrettyQrBrush.from(background);
      context.canvas.drawRect(
        context.estimatedBounds,
        backgroundBrush.toPaint(
          context.estimatedBounds,
          textDirection: context.textDirection,
        ),
      );
    }

    final quietZone = decoration.quietZone.resolveWidth(context);
    if (quietZone > 0) {
      context.canvas.translate(quietZone, quietZone);
      context.canvas.scale(1 - quietZone * 2 / context.boundsDimension);
    }

    final image = decoration.image;
    if (image != null) {
      final size = context.estimatedBounds.size;
      final imageScale = image.scale.clamp(0.0, 1.0);
      
      // Create the image painter
      _decorationImagePainter ??= image.createPainter(onChanged);
      
      // Attempt to resolve image dimensions if not already done
      if (!_imageResolutionAttempted) {
        _imageResolutionAttempted = true;
        _resolveImageAspectRatio(image, configuration);
      }
      
      // Calculate the area based on actual image aspect ratio if available
      final baseSize = size.width * imageScale;
      late final Rect imageScaledRect;
      late final Rect moduleClearingRect;
      
      if (_imageAspectRatio != null && _imageAspectRatio! > 0) {
        // Use the detected aspect ratio to calculate proper dimensions
        final aspectRatio = _imageAspectRatio!;
        late final double imageWidth, imageHeight;
        
        if (aspectRatio >= 1.0) {
          // Landscape or square: width is the constraining dimension
          imageWidth = baseSize;
          imageHeight = baseSize / aspectRatio;
        } else {
          // Portrait: height is the constraining dimension
          imageHeight = baseSize;
          imageWidth = baseSize * aspectRatio;
        }
        
        imageScaledRect = Rect.fromCenter(
          center: size.center(Offset.zero),
          width: imageWidth,
          height: imageHeight,
        );
        moduleClearingRect = imageScaledRect;
      } else {
        // Fallback to square for backward compatibility or when aspect ratio can't be determined
        imageScaledRect = Rect.fromCenter(
          center: size.center(Offset.zero),
          width: baseSize,
          height: baseSize,
        );
        moduleClearingRect = imageScaledRect;
      }

      // Clear space for the embedded image
      if (image.position == PrettyQrDecorationImagePosition.embedded) {
        for (final module in context.matrix) {
          final moduleRect = module.resolveRect(context);
          if (moduleClearingRect.overlaps(moduleRect)) {
            context.matrix.removeDarkAt(module.x, module.y);
          }
        }
      }

      if (image.position == PrettyQrDecorationImagePosition.foreground) {
        decoration.shape.paint(context);
      }

      final imagePadding = (image.padding * imageScale).resolve(
        configuration.textDirection,
      );
      final imageCroppedRect = imagePadding.deflateRect(imageScaledRect);

      // Create painters for both primary and fallback images
      _decorationImagePainter ??= image.createPainter(onChanged);
      
      if (image.fallbackImage != null && _fallbackImagePainter == null) {
        // Create a fallback image painter with the same properties but different image
        final fallbackImageDecoration = PrettyQrDecorationImage(
          image: image.fallbackImage!,
          scale: image.scale,
          onError: image.onError,
          colorFilter: image.colorFilter,
          fit: image.fit,
          repeat: image.repeat,
          matchTextDirection: image.matchTextDirection,
          opacity: image.opacity,
          filterQuality: image.filterQuality,
          invertColors: image.invertColors,
          isAntiAlias: image.isAntiAlias,
          padding: image.padding,
          borderRadius: image.borderRadius,
          position: image.position,
        );
        _fallbackImagePainter = fallbackImageDecoration.createPainter(onChanged);
      }
      
      // Choose which painter to use
      final painterToUse = _useFallbackImage && _fallbackImagePainter != null 
          ? _fallbackImagePainter! 
          : _decorationImagePainter!;
      
      // Apply rounded corners if borderRadius is set
      if (image.borderRadius != BorderRadius.zero) {
        // Safety check to ensure we have a valid rect before proceeding
        if (imageCroppedRect != null &&
            !imageCroppedRect.isEmpty &&
            imageCroppedRect.isFinite) {
          try {
            final rrect = RRect.fromRectAndCorners(
              imageCroppedRect,
              topLeft: image.borderRadius.topLeft,
              topRight: image.borderRadius.topRight,
              bottomLeft: image.borderRadius.bottomLeft,
              bottomRight: image.borderRadius.bottomRight,
            );

            context.canvas.save();
            context.canvas.clipRRect(rrect);

            painterToUse.paint(
              context.canvas,
              imageCroppedRect,
              null,
              configuration.copyWith(size: imageCroppedRect.size),
            );

            context.canvas.restore();
          } catch (e) {
            // Fallback to the non-rounded version if there's an error
            painterToUse.paint(
              context.canvas,
              imageCroppedRect,
              null,
              configuration.copyWith(size: imageCroppedRect.size),
            );
          }
        } else {
          // If the rect is invalid, just paint without rounded corners
          painterToUse.paint(
            context.canvas,
            imageCroppedRect,
            null,
            configuration.copyWith(size: imageCroppedRect.size),
          );
        }
      } else {
        painterToUse.paint(
          context.canvas,
          imageCroppedRect,
          null,
          configuration.copyWith(size: imageCroppedRect.size),
        );
      }
    }

    if (image?.position != PrettyQrDecorationImagePosition.foreground) {
      decoration.shape.paint(context);
    }
  }
  
  /// Attempts to resolve the image and extract its aspect ratio
  void _resolveImageAspectRatio(PrettyQrDecorationImage image, ImageConfiguration configuration) {
    try {
      final imageStream = image.image.resolve(configuration);
      late ImageStreamListener listener;
      
      listener = ImageStreamListener(
        (ImageInfo imageInfo, bool synchronousCall) {
          imageStream.removeListener(listener);
          final loadedImage = imageInfo.image;
          if (loadedImage.width > 0 && loadedImage.height > 0) {
            _imageAspectRatio = loadedImage.width / loadedImage.height;
            _useFallbackImage = false; // Primary image loaded successfully
            // Trigger a repaint with the new aspect ratio
            onChanged();
          }
          imageInfo.dispose();
        },
        onError: (exception, stackTrace) {
          imageStream.removeListener(listener);
          // Primary image failed, try fallback if available
          if (image.fallbackImage != null) {
            _tryFallbackImage(image, configuration);
          } else {
            // No fallback available, keep default square behavior
            _useFallbackImage = false;
          }
        },
      );
      
      imageStream.addListener(listener);
    } catch (e) {
      // If resolution fails, try fallback or keep default square behavior
      if (image.fallbackImage != null) {
        _tryFallbackImage(image, configuration);
      } else {
        _useFallbackImage = false;
      }
    }
  }
  
  /// Attempts to resolve the fallback image
  void _tryFallbackImage(PrettyQrDecorationImage image, ImageConfiguration configuration) {
    if (image.fallbackImage == null) return;
    
    try {
      final fallbackStream = image.fallbackImage!.resolve(configuration);
      late ImageStreamListener fallbackListener;
      
      fallbackListener = ImageStreamListener(
        (ImageInfo imageInfo, bool synchronousCall) {
          fallbackStream.removeListener(fallbackListener);
          final fallbackImage = imageInfo.image;
          if (fallbackImage.width > 0 && fallbackImage.height > 0) {
            _imageAspectRatio = fallbackImage.width / fallbackImage.height;
            _useFallbackImage = true; // Use fallback image
            // Trigger a repaint with the fallback image
            onChanged();
          }
          imageInfo.dispose();
        },
        onError: (exception, stackTrace) {
          fallbackStream.removeListener(fallbackListener);
          // Both primary and fallback failed, keep default behavior
          _useFallbackImage = false;
        },
      );
      
      fallbackStream.addListener(fallbackListener);
    } catch (e) {
      // Fallback resolution failed, keep default behavior
      _useFallbackImage = false;
    }
  }

  /// Discard any resources being held by the object.
  @mustCallSuper
  void dispose() {
    _decorationImagePainter?.dispose();
    _decorationImagePainter = null;
    _fallbackImagePainter?.dispose();
    _fallbackImagePainter = null;
  }
}
