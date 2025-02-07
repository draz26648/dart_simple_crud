abstract class IFileService {
  Future<void> initialize();
  bool isValidImageFile(String fileName);
  String generateUniqueFileName(String originalFileName);
  Future<String?> saveProfileImage(String fileName, List<int> fileBytes);
  Future<bool> deleteProfileImage(String? filePath);
}
