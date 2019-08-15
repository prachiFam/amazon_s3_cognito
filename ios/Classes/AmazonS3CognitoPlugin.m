#import "AmazonS3CognitoPlugin.h"
#import <amazon_s3_cognito/amazon_s3_cognito-Swift.h>

@implementation AmazonS3CognitoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAmazonS3CognitoPlugin registerWithRegistrar:registrar];
}
@end
