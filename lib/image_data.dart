class ImageData {
  String fileName;
  String filePath;
  String? uniqueId;

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
}
