class FileUtils {
  /// 获取文件名
  static String getFileName(String? path) {
    if (path == null) {
      return "";
    }
    int index = path.lastIndexOf("/");
    if (index >= 0) {
      return path.substring(index + 1, path.length - 4);
    } else {
      return path;
    }
  }
}
