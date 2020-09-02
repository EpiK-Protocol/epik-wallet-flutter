#import "FlutterpluginPlugin.h"

@implementation FlutterpluginPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"epikplugin"
                                     binaryMessenger:[registrar messenger]];
    FlutterpluginPlugin* instance = [[FlutterpluginPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSError *err = nil;
    NSDictionary *arguments = [call arguments];
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    }else if ([@"hd_hd_newMnemonic" isEqualToString:call.method]) {
        NSString *mnemonic = EPIK_HdNewMnemonic([arguments[@"bits"] intValue], &err);
        if (!err){
            result(mnemonic);
        }
    }else if ([@"hd_hd_newFromMnemonic" isEqualToString:call.method]) {
        _hdWallet = EPIK_HdNewFromMnemonic(arguments[@"mnemonic"], &err);
        if (!err) {
            result(@"");
        }
    }else if ([@"hd_hd_newFromSeed" isEqualToString:call.method]) {
        _hdWallet = EPIK_HdNewFromSeed([arguments[@"seed"] data] , &err);
        if (!err) {
            result(@"");
        }
    }else if ([@"hd_hd_newSeed" isEqualToString:call.method]) {
        NSData *seed = EPIK_HdNewSeed(&err);
        FlutterStandardTypedData *data = [FlutterStandardTypedData typedDataWithBytes:seed];
        if (!err){
            result(data);
        }
    }else if ([@"hd_hd_seedFromMnemonic" isEqualToString:call.method]) {
        NSData *seed = EPIK_HdSeedFromMnemonic(arguments[@"mnemonic"], &err);
        FlutterStandardTypedData *data = [FlutterStandardTypedData typedDataWithBytes:seed];
        if (!err){
            result(data);
        }
    }else if ([@"hd_wallet_balance" isEqualToString:call.method]) {
        if (_hdWallet){
            NSString *balance = [_hdWallet balance:arguments[@"address"] error:&err];
            if (!err) {
                result(balance);
            }
        }else{
            err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
        }
    }else if ([@"hd_wallet_contains" isEqualToString:call.method]) {
        if (_hdWallet){
            BOOL has = [_hdWallet contains:arguments[@"address"]];
            if (!err) {
                result([NSNumber numberWithBool:has]);
            }
        }else{
            err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
        }
    }else if ([@"hd_wallet_derive" isEqualToString:call.method]) {
        if (_hdWallet){
            NSString *address = [_hdWallet derive:arguments[@"path"] pin:[arguments[@"pin"] boolValue] error:&err];
            if (!err) {
                 result(address);
            }
        }else{
            err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
        }
    }else if ([@"hd_wallet_setRPC" isEqualToString:call.method]) {
        if (_hdWallet){
            [_hdWallet setRPC:arguments[@"url"] error:&err];
            if (!err) {
                result(@"");
            }
        }else{
            err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
        }
    }else if ([@"hd_wallet_signHash" isEqualToString:call.method]) {
        if (_hdWallet){
            NSData *sign = [_hdWallet signHash:arguments[@"address"] hash:[arguments[@"hash"] data] error:&err];
            FlutterStandardTypedData *data = [FlutterStandardTypedData typedDataWithBytes:sign];
            if (!err) {
                 result(data);
            }
        }else{
            err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
        }
    }else if ([@"hd_wallet_signText" isEqualToString:call.method]) {
        if (_hdWallet){
            NSData *sign = [_hdWallet signText:arguments[@"address"] text:arguments[@"text"] error:&err];
            FlutterStandardTypedData *data = [FlutterStandardTypedData typedDataWithBytes:sign];
            if (!err) {
                 result(data);
            }
        }else{
            err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
        }
    }else if ([@"hd_wallet_tokenBalance" isEqualToString:call.method]) {
        if (_hdWallet){
            NSString *balance = [_hdWallet tokenBalance:arguments[@"address"] currency:arguments[@"currency"] error:&err];
            if (!err) {
                 result(balance);
            }
        }else{
            err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
        }
    }else if ([@"hd_wallet_transactions" isEqualToString:call.method]) {
        if (_hdWallet){
            NSString *txs = [_hdWallet transactions:arguments[@"address"] currency:arguments[@"currency"] page:[arguments[@"page"] intValue] offset:[arguments[@"offset"] intValue] asc:[arguments[@"asc"] boolValue] error:&err];
            if (!err) {
                 result(txs);
            }
        }else{
            err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
        }
    }else if ([@"hd_wallet_transfer" isEqualToString:call.method]) {
        if (_hdWallet){
            NSString *txhash = [_hdWallet transfer:arguments[@"from"] to:arguments[@"to"] amount:arguments[@"amount"] error:&err];
            if (!err) {
                 result(txhash);
            }
        }else{
            err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
        }
    }else if ([@"hd_wallet_transferToken" isEqualToString:call.method]) {
        if (_hdWallet){
            NSString *txhash = [_hdWallet transferToken:arguments[@"from"] to:arguments[@"to"] currency:arguments[@"currency"] amount:arguments[@"amount"] error:&err];
            if (!err) {
                 result(txhash);
            }
        }else{
            err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
        }
    }else if ([@"epik_epik_newWallet" isEqualToString:call.method]) {
        _epikWallet = EPIK_EpikNewWallet(&err);
        if (!err) {
            result(@"");
        }
    }else if ([@"epik_wallet_balance" isEqualToString:call.method]) {
        if (_hdWallet){
            NSString *balance = [_epikWallet balance:arguments[@"addr"] error:&err];
            if (!err) {
                 result(balance);
            }
        }else{
            err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
        }
    }else if ([@"epik_wallet_export" isEqualToString:call.method]) {
        if (_hdWallet){
            EPIK_EpikPrivateKey *privateKey = [_epikWallet export:arguments[@"addr"] error:&err];
            if (!err) {
                result(@{@"keyType":privateKey.keyType,@"privateKey":privateKey.privateKey});
            }
        }else{
            err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
        }
    }else if ([@"epik_wallet_generateKey" isEqualToString:call.method]) {
        if (_hdWallet){
            NSString *address = [_epikWallet generateKey:arguments[@"t"] seed:[arguments[@"seed"] data] error:&err];
            if (!err) {
                result(address);
            }
        }else{
            err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
        }
    }else if ([@"epik_wallet_hasAddr" isEqualToString:call.method]) {
        if (_hdWallet){
            BOOL has = [_epikWallet hasAddr:arguments[@"addr"]];
            if (!err) {
                result([NSNumber numberWithBool:has]);
            }
        }else{
            err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
        }
    }else if ([@"epik_wallet_messageList" isEqualToString:call.method]) {
        if (_hdWallet){
            NSString *messages = [_epikWallet messageList:[arguments[@"toHeight"] intValue] addr:arguments[@"addr"] error:&err];
            if (!err) {
                result(messages);
            }
        }else{
            err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
        }
    }else if ([@"epik_wallet_setDefault" isEqualToString:call.method]) {
        if (_hdWallet){
            [_epikWallet setDefault:arguments[@"addr"] error:&err];
            if (!err) {
                result(@"");
            }
        }else{
            err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
        }
    }else if ([@"epik_wallet_setRPC" isEqualToString:call.method]) {
        if (_hdWallet){
            [_epikWallet setRPC:arguments[@"url"] token:arguments[@"token"] error:&err];
            if (!err) {
                result(@"");
            }
        }else{
            err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
        }
    }else if ([@"epik_wallet_sign" isEqualToString:call.method]) {
        if (_hdWallet){
            NSData *sign = [_epikWallet sign:arguments[@"addr"] hash:[arguments[@"hash"] data] error:&err];
            if (!err) {
                result([FlutterStandardTypedData typedDataWithBytes:sign]);
            }
        }else{
            err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
        }
    }else if ([@"epik_wallet_send" isEqualToString:call.method]) {
        if (_hdWallet){
            NSString *txHash = [_epikWallet send:arguments[@"to"] amount:arguments[@"amount"] error:&err];
            if (!err) {
                result(txHash);
            }
        }else{
            err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
        }
    }else {
        result(FlutterMethodNotImplemented);
    }
    if (err) {
        result([FlutterError errorWithCode:@"-1" message:[err localizedDescription] details:[err localizedFailureReason]]);
    }
}
@end
