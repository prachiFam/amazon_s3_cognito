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

  void fromMap(LinkedHashMap<Object?, Object?> map) {
    if (map["fileName"] != null) {
      fileName = map["fileName"].toString();
    }

    if (map["filePath"] != null) {
      filePath = map["filePath"].toString();
    }

    if (map["amazonImageUrl"] != null) {
      amazonUrl = map["amazonImageUrl"].toString();
    }

    if (map["progress"] != null) {
      progress = double.parse(map["progress"].toString().trim());
    }

    state = map["state"]?.toString();
    if (map["isUploadError"] != null) {
      isUploadError = map["isUploadError"] as bool;
    }
  }
}
