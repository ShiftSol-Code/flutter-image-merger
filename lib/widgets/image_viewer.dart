import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class DraggableImageViewer extends StatefulWidget {
  final Uint8List imageBytes;

  const DraggableImageViewer({
    super.key,
    required this.imageBytes,
  });

  @override
  State<DraggableImageViewer> createState() => _DraggableImageViewerState();
}

class _DraggableImageViewerState extends State<DraggableImageViewer> {
  final TransformationController _transformationController = TransformationController();
  
  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.1,
        maxScale: 20.0,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        // 마우스 드래그로 팬(이동) 가능하도록 설정
        panEnabled: true,
        scaleEnabled: true,
        // 마우스 휠로 줌 가능
        scaleFactor: 200.0,
        child: Center(
          child: Image.memory(
            widget.imageBytes,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

/// 더 세밀한 제어가 필요한 경우를 위한 커스텀 드래그 뷰어
class CustomDraggableImageViewer extends StatefulWidget {
  final Uint8List imageBytes;

  const CustomDraggableImageViewer({
    super.key,
    required this.imageBytes,
  });

  @override
  State<CustomDraggableImageViewer> createState() => _CustomDraggableImageViewerState();
}

class _CustomDraggableImageViewerState extends State<CustomDraggableImageViewer> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        _previousScale = _scale;
        _previousOffset = _offset;
      },
      onScaleUpdate: (details) {
        setState(() {
          _scale = (_previousScale * details.scale).clamp(0.1, 20.0);
          
          // 팬(드래그) 처리
          final delta = details.focalPointDelta;
          _offset = _previousOffset + delta;
        });
      },
      // 마우스 드래그 스크롤 지원
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            setState(() {
              // 마우스 휠로 줌
              final delta = event.scrollDelta.dy;
              _scale = (_scale - delta / 500).clamp(0.1, 20.0);
            });
          }
        },
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(_offset.dx, _offset.dy)
                    ..scale(_scale),
                  alignment: Alignment.center,
                  child: Image.memory(
                    widget.imageBytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // 줌 레벨 표시
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(_scale * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // 리셋 버튼
              Positioned(
                bottom: 16,
                left: 16,
                child: FloatingActionButton.small(
                  onPressed: () {
                    setState(() {
                      _scale = 1.0;
                      _offset = Offset.zero;
                      _previousScale = 1.0;
                      _previousOffset = Offset.zero;
                    });
                  },
                  tooltip: '원래 크기로',
                  child: const Icon(Icons.refresh),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
