import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amazon_s3_cognito/amazon_s3_cognito.dart';

void main() {
  const MethodChannel channel = MethodChannel('amazon_s3_cognito');

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (message) async => '42',
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (message) => null,
    );
  });

  test('getPlatformVersion', () async {
    expect(await AmazonS3Cognito.platformVersion, '42');
  });
}
