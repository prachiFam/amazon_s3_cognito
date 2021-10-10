import 'dart:collection';

class ImageData {
  String fileName;
  String filePath;
  String? uniqueId;

  String? amazonUrl;
  double? progress;
  String? state;
  bool isUploadError = false;

  ImageData(this.fileName, this.filePath, {this.uniqueId});

  // named constructor
  ImageData.fromJson(Map<String, dynamic> json)
      : fileName = json['fileName'],
        filePath = json['filePath'],
        uniqueId = json['uniqueId'];

  // method
  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'filePath': filePath,
      'uniqueId': uniqueId,
    };
  }

  void copy(ImageData another) {
    fileName = another.fileName;
    filePath = another.filePath;
    amazonUrl = another.amazonUrl;
    progress = another.progress;
    state = another.state;
    isUploadError = another.isUploadError;
  }

  void fromMap(HashMap map) {
    fileName = map["fileName"];
    filePath = map["filePath"];
    amazonUrl = map["amazonImageUrl"];
    progress = map["progress"];
    state = map["state"];
    isUploadError = map["isUploadError"];
  }
}
