#import <Flutter/Flutter.h>
#import <epik/epik.h>

@interface FlutterpluginPlugin : NSObject<FlutterPlugin>

@property EPIK_EpikWallet *epikWallet;

@property EPIK_HdWallet *hdWallet;

@end
