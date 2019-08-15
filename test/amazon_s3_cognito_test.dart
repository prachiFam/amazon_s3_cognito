import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amazon_s3_cognito/amazon_s3_cognito.dart';

void main() {
  const MethodChannel channel = MethodChannel('amazon_s3_cognito');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await AmazonS3Cognito.platformVersion, '42');
  });
}
