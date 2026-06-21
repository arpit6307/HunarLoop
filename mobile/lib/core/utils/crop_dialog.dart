import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../theme/app_colors.dart';

class CropBrutalistCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final double shadowOffset;
  final EdgeInsetsGeometry? padding;

  const CropBrutalistCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.shadowOffset = 4.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 3.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(shadowOffset, shadowOffset),
            blurRadius: 0,
            spreadRadius: 0,
          )
        ],
      ),
      child: child,
    );
  }
}

class CropDialog extends StatefulWidget {
  final String imageBase64;
  final bool isCover;
  final bool isPortfolio;

  const CropDialog({super.key, required this.imageBase64, this.isCover = false, this.isPortfolio = false});

  @override
  State<CropDialog> createState() => _CropDialogState();
}

class _CropDialogState extends State<CropDialog> {
  final GlobalKey _repaintKey = GlobalKey();
  final TransformationController _transformController = TransformationController();
  double _zoom = 1.0;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  Future<void> _cropAndSave() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      // Capture the RepaintBoundary as a ui.Image
      final ui.Image capturedImage = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await capturedImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      final base64Result = 'data:image/png;base64,${base64Encode(pngBytes)}';
      
      if (mounted) {
        Navigator.of(context).pop(base64Result);
      }
    } catch (e) {
      debugPrint('Error cropping image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ERROR CROPPING IMAGE: ${e.toString().toUpperCase()}'),
            backgroundColor: Colors.black,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Clean base64 prefix if present
    final cleanBase64 = widget.imageBase64.contains(',')
        ? widget.imageBase64.split(',').last
        : widget.imageBase64;
    final bytes = base64Decode(cleanBase64);

    final String titleText;
    final String descText;
    if (widget.isCover) {
      titleText = 'CROP COVER BANNER';
      descText = 'PAN AND PINCH TO ZOOM THE IMAGE INSIDE THE BANNER.';
    } else if (widget.isPortfolio) {
      titleText = 'CROP PORTFOLIO PHOTO';
      descText = 'PAN AND PINCH TO ZOOM THE IMAGE INSIDE THE SQUARE.';
    } else {
      titleText = 'CROP PROFILE PICTURE';
      descText = 'PAN AND PINCH TO ZOOM THE IMAGE INSIDE THE SQUARE.';
    }

    final double containerW = widget.isCover ? 280 : 200;
    final double containerH = widget.isCover ? 100 : 200;
    final decoration = BoxDecoration(
      color: Colors.grey[200],
      shape: BoxShape.rectangle,
      border: Border.all(color: Colors.black, width: 3.0),
    );

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Colors.black, width: 3.0),
      ),
      title: Text(
        titleText,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            descText,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Repaint boundary wraps the viewport
          RepaintBoundary(
            key: _repaintKey,
            child: Container(
              width: containerW,
              height: containerH,
              decoration: decoration,
              child: ClipRect(
                child: InteractiveViewer(
                  transformationController: _transformController,
                  boundaryMargin: const EdgeInsets.all(150.0),
                  minScale: 0.1,
                  maxScale: 5.0,
                  onInteractionUpdate: (details) {
                    setState(() {
                      _zoom = _transformController.value.getMaxScaleOnAxis();
                    });
                  },
                  child: Image.memory(
                    bytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Custom zoom controls in Neo-Brutalist style
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _zoom = (_zoom - 0.2).clamp(0.1, 5.0);
                    _transformController.value = Matrix4.diagonal3Values(_zoom, _zoom, 1.0);
                  });
                },
                child: const CropBrutalistCard(
                  color: Colors.white,
                  shadowOffset: 2.0,
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.remove, size: 20, color: Colors.black),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'ZOOM: ${(_zoom * 100).toInt()}%',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _zoom = (_zoom + 0.2).clamp(0.1, 5.0);
                    _transformController.value = Matrix4.diagonal3Values(_zoom, _zoom, 1.0);
                  });
                },
                child: const CropBrutalistCard(
                  color: Colors.white,
                  shadowOffset: 2.0,
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.add, size: 20, color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        TextButton(
          onPressed: _cropAndSave,
          child: const Text('CROP & SAVE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }
}
