
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import '../services/image_service.dart';
import '../widgets/image_viewer.dart';

class ImageMergerScreen extends StatefulWidget {
  const ImageMergerScreen({super.key});

  @override
  State<ImageMergerScreen> createState() => _ImageMergerScreenState();
}

class _ImageMergerScreenState extends State<ImageMergerScreen> {
  final ImageService _imageService = ImageService();
  final List<String> _selectedImagePaths = [];
  Uint8List? _mergedImageBytes;
  bool _isPreviewLoading = false;
  bool _isDragging = false;
  
  // Split View State
  double _listHeightRatio = 0.4; // Initial ratio for the list (40%)
  bool _isFullScreen = false;

  Future<void> _pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final paths = result.paths.whereType<String>().toList();
        setState(() {
          _selectedImagePaths.addAll(paths);
        });
        _updateMergedPreview();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 선택 중 오류 발생: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateMergedPreview() async {
    if (_selectedImagePaths.isEmpty) {
      setState(() {
        _mergedImageBytes = null;
      });
      return;
    }

    setState(() {
      _isPreviewLoading = true;
    });

    try {
      final mergedBytes = await _imageService.mergeImagesVertically(_selectedImagePaths);
      setState(() {
        _mergedImageBytes = mergedBytes;
        _isPreviewLoading = false;
      });
    } catch (e) {
      setState(() {
        _isPreviewLoading = false;
      });
      // Preview generation failed, maybe silently ignore or log?
      // For now, let's just not update the preview if it fails.
      debugPrint('Preview generation failed: $e');
    }
  }

  Future<void> _mergeAndSave() async {
    if (_selectedImagePaths.isEmpty) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('파일을 생성중입니다. 잠시만 기다려 주세요'),
              ],
            ),
          ),
        );
      },
    );

    try {
      // 1. Merge Images (We could reuse _mergedImageBytes if it's up to date, but to be safe and ensure "Processing" feel, let's re-merge or just use the bytes)
      // The user wants "Processing" animation. If we use cached bytes, it might be too fast.
      // But re-merging is safer to ensure we have the latest state.
      final mergedBytes = await _imageService.mergeImagesVertically(_selectedImagePaths);

      // 2. Save Image
      if (mounted) {
        Navigator.of(context).pop(); 
        
        final path = await _imageService.saveImageWithDialog(mergedBytes);
        
        if (path != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('이미지 저장 완료: $path'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Ensure dialog is closed on error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('작업 중 오류 발생: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearImages() {
    setState(() {
      _selectedImagePaths.clear();
      _mergedImageBytes = null;
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImagePaths.removeAt(index);
    });
    _updateMergedPreview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_isFullScreen ? '미리보기 (전체화면)' : '이미지 합치기'),
        actions: [
          if (_selectedImagePaths.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _clearImages,
              tooltip: '초기화',
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final totalHeight = constraints.maxHeight;
          final listHeight = totalHeight * _listHeightRatio;
          // Ensure list height is within reasonable bounds (e.g., min 100, max total - 100)
          final clampedListHeight = listHeight.clamp(100.0, totalHeight - 100.0);
          
          return DropTarget(
            onDragEntered: (details) {
              setState(() {
                _isDragging = true;
              });
            },
            onDragExited: (details) {
              setState(() {
                _isDragging = false;
              });
            },
            onDragDone: (details) {
              setState(() {
                _isDragging = false;
              });

              final imagePaths = details.files
                  .where((file) => file.path.toLowerCase().endsWith('.png') ||
                      file.path.toLowerCase().endsWith('.jpg') ||
                      file.path.toLowerCase().endsWith('.jpeg') ||
                      file.path.toLowerCase().endsWith('.gif') ||
                      file.path.toLowerCase().endsWith('.bmp') ||
                      file.path.toLowerCase().endsWith('.webp'))
                  .map((file) => file.path)
                  .toList();

              if (imagePaths.isNotEmpty) {
                setState(() {
                  _selectedImagePaths.addAll(imagePaths);
                });
                _updateMergedPreview();
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('이미지 파일만 업로드 가능합니다.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
            child: Container(
              decoration: _isDragging
                  ? BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                        width: 3,
                      ),
                      color: Colors.blue.withOpacity(0.1),
                    )
                  : null,
              child: _selectedImagePaths.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.image,
                            size: 100,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _isDragging
                                ? '여기에 이미지를 드롭하세요'
                                : '이미지를 선택하거나 드래그하여 목록에 추가',
                            style: TextStyle(
                              fontSize: 18,
                              color: _isDragging ? Colors.blue : Colors.grey,
                              fontWeight: _isDragging ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('이미지 업로드'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Top Section: Image List (Hidden in Full Screen)
                        if (!_isFullScreen)
                          SizedBox(
                            height: clampedListHeight,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '선택된 이미지 (${_selectedImagePaths.length}개)',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: _pickImages,
                                            icon: const Icon(Icons.add_photo_alternate),
                                            label: const Text('추가'),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            onPressed: _mergeAndSave,
                                            icon: const Icon(Icons.save),
                                            label: const Text('저장'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context).colorScheme.primary,
                                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _selectedImagePaths.length,
                                    itemBuilder: (context, index) {
                                      final path = _selectedImagePaths[index];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                        child: ListTile(
                                          leading: Image.file(
                                            File(path),
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          ),
                                          title: Text(
                                            path.split(Platform.pathSeparator).last,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          subtitle: Text(path, overflow: TextOverflow.ellipsis),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.close),
                                            onPressed: () => _removeImage(index),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Resizer Handle (Hidden in Full Screen)
                        if (!_isFullScreen)
                          GestureDetector(
                            onVerticalDragUpdate: (details) {
                              setState(() {
                                _listHeightRatio += details.delta.dy / totalHeight;
                                // Clamp ratio between 0.1 and 0.9
                                _listHeightRatio = _listHeightRatio.clamp(0.1, 0.9);
                              });
                            },
                            child: Container(
                              height: 20,
                              color: Colors.grey[200],
                              child: Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Bottom Section: Preview
                        Expanded(
                          child: Container(
                            color: Colors.grey[100],
                            child: Column(
                              children: [
                                // Preview Header
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  color: Colors.grey[200],
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '미리보기',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _isFullScreen = !_isFullScreen;
                                          });
                                        },
                                        icon: Icon(_isFullScreen ? Icons.list : Icons.fullscreen),
                                        label: Text(_isFullScreen ? '목록보기' : '전체화면'),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: _isPreviewLoading
                                      ? const Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(height: 8),
                                              Text('미리보기 생성 중...'),
                                            ],
                                          ),
                                        )
                                      : _mergedImageBytes != null
                                          ? DraggableImageViewer(
                                              imageBytes: _mergedImageBytes!,
                                            )
                                          : const Center(
                                              child: Text(
                                                '이미지가 없습니다',
                                                style: TextStyle(color: Colors.grey),
                                              ),
                                            ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
