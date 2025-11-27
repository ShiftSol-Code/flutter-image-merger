import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:file_selector/file_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageService {
  /// 여러 이미지를 세로로 합치는 함수
  Future<Uint8List> mergeImagesVertically(List<String> imagePaths) async {
    if (imagePaths.isEmpty) {
      throw Exception('이미지가 선택되지 않았습니다.');
    }

    // 모든 이미지 로드
    List<img.Image> images = [];
    int maxWidth = 0;
    int totalHeight = 0;

    for (String imagePath in imagePaths) {
      final bytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('이미지를 디코딩할 수 없습니다: $imagePath');
      }

      images.add(image);
      if (image.width > maxWidth) {
        maxWidth = image.width;
      }
      totalHeight += image.height;
    }

    // 새로운 캔버스 생성 (최대 너비 x 총 높이)
    final mergedImage = img.Image(width: maxWidth, height: totalHeight);
    
    // 배경을 흰색으로 채우기
    img.fill(mergedImage, color: img.ColorRgb8(255, 255, 255));

    // 이미지들을 세로로 붙이기
    int currentY = 0;
    for (var image in images) {
      // 이미지를 중앙 정렬
      int x = (maxWidth - image.width) ~/ 2;
      
      img.compositeImage(
        mergedImage,
        image,
        dstX: x,
        dstY: currentY,
      );
      
      currentY += image.height;
    }

    // PNG로 인코딩
    final pngBytes = img.encodePng(mergedImage);
    return Uint8List.fromList(pngBytes);
  }

  /// 합쳐진 이미지를 파일로 저장
  Future<String> saveImage(Uint8List imageBytes) async {
    try {
      // 저장 경로 가져오기
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'merged_image_$timestamp.png';
      final filePath = path.join(directory.path, fileName);

      // 파일 저장
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      return filePath;
    } catch (e) {
      throw Exception('이미지 저장 실패: $e');
    }
  }

  /// 사용자 지정 경로로 이미지 저장 (다이얼로그 포함)
  Future<String?> saveImageWithDialog(Uint8List imageBytes) async {
    try {
      // 저장된 경로 불러오기
      String? initialDirectory = await _getSavePath();
      
      // 파일 이름 생성
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final suggestedName = 'merged_image_$timestamp.png';

      // 저장 위치 선택 다이얼로그
      final FileSaveLocation? result = await getSaveLocation(
        suggestedName: suggestedName,
        initialDirectory: initialDirectory,
        acceptedTypeGroups: [
          const XTypeGroup(
            label: 'PNG Images',
            extensions: ['png'],
          ),
        ],
      );

      if (result == null) {
        // 사용자가 취소함
        return null;
      }

      // 선택한 경로 저장
      final selectedPath = result.path;
      final directory = path.dirname(selectedPath);
      await _setSavePath(directory);

      // 파일 저장
      final file = File(selectedPath);
      await file.writeAsBytes(imageBytes);

      return selectedPath;
    } catch (e) {
      throw Exception('이미지 저장 실패: $e');
    }
  }

  /// SharedPreferences에서 저장 경로 불러오기
  Future<String?> _getSavePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('save_path');
    } catch (e) {
      return null;
    }
  }

  /// SharedPreferences에 저장 경로 저장
  Future<void> _setSavePath(String savePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('save_path', savePath);
    } catch (e) {
      // 저장 실패해도 계속 진행
    }
  }
}
