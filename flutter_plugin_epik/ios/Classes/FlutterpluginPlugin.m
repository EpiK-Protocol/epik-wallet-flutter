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
    FlutterResult resultSync = ^(id res){
        dispatch_async(dispatch_get_main_queue(), ^{result(res);});
    };
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue , ^(){
        
        NSError *err = nil;
        NSDictionary *arguments = [call arguments];
        if ([@"getPlatformVersion" isEqualToString:call.method]) {
            resultSync([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
        }else if ([@"hd_hd_newMnemonic" isEqualToString:call.method]) {
            NSString *mnemonic = EPIK_HdNewMnemonic([arguments[@"bits"] intValue], &err);
            if (!err){
                resultSync(mnemonic);
            }
        }else if ([@"hd_hd_newFromMnemonic" isEqualToString:call.method]) {
            self->_hdWallet = EPIK_HdNewFromMnemonic(arguments[@"mnemonic"], &err);
            if (!err) {
                resultSync(@"");
            }
        }else if ([@"hd_hd_newFromSeed" isEqualToString:call.method]) {
            self->_hdWallet = EPIK_HdNewFromSeed([arguments[@"seed"] data] , &err);
            if (!err) {
                resultSync(@"");
            }
        }else if ([@"hd_hd_newSeed" isEqualToString:call.method]) {
            NSData *seed = EPIK_HdNewSeed(&err);
            FlutterStandardTypedData *data = [FlutterStandardTypedData typedDataWithBytes:seed];
            if (!err){
                resultSync(data);
            }
        }else if ([@"hd_hd_seedFromMnemonic" isEqualToString:call.method]) {
            NSData *seed = EPIK_HdSeedFromMnemonic(arguments[@"mnemonic"], &err);
            FlutterStandardTypedData *data = [FlutterStandardTypedData typedDataWithBytes:seed];
            if (!err){
                resultSync(data);
            }
        }else if ([@"hd_wallet_accounts" isEqualToString:call.method]) {
            NSString *accounts = [self->_hdWallet accounts];
            resultSync(accounts);
        }else if ([@"hd_wallet_balance" isEqualToString:call.method]) {
            if (self->_hdWallet){
                NSString *balance = [self->_hdWallet balance:arguments[@"address"] error:&err];
                if (!err) {
                    resultSync(balance);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"hd_wallet_contains" isEqualToString:call.method]) {
            if (self->_hdWallet){
                BOOL has = [self->_hdWallet contains:arguments[@"address"]];
                if (!err) {
                    resultSync([NSNumber numberWithBool:has]);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"hd_wallet_derive" isEqualToString:call.method]) {
            if (self->_hdWallet){
                NSString *address = [self->_hdWallet derive:arguments[@"path"] pin:[arguments[@"pin"] boolValue] error:&err];
                if (!err) {
                    resultSync(address);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"hd_wallet_setRPC" isEqualToString:call.method]) {
            if (self->_hdWallet){
                [self->_hdWallet setRPC:arguments[@"url"] error:&err];
                if (!err) {
                    resultSync(@"");
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"hd_wallet_signHash" isEqualToString:call.method]) {
            if (self->_hdWallet){
                NSData *sign = [self->_hdWallet signHash:arguments[@"address"] hash:[arguments[@"hash"] data] error:&err];
                FlutterStandardTypedData *data = [FlutterStandardTypedData typedDataWithBytes:sign];
                if (!err) {
                    resultSync(data);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"hd_wallet_signText" isEqualToString:call.method]) {
            if (self->_hdWallet){
                NSData *sign = [self->_hdWallet signText:arguments[@"address"] text:arguments[@"text"] error:&err];
                FlutterStandardTypedData *data = [FlutterStandardTypedData typedDataWithBytes:sign];
                if (!err) {
                    resultSync(data);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"hd_wallet_tokenBalance" isEqualToString:call.method]) {
            if (self->_hdWallet){
                NSString *balance = [self->_hdWallet tokenBalance:arguments[@"address"] currency:arguments[@"currency"] error:&err];
                if (!err) {
                    resultSync(balance);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"hd_wallet_transactions" isEqualToString:call.method]) {
            if (self->_hdWallet){
                NSString *txs = [self->_hdWallet transactions:arguments[@"address"] currency:arguments[@"currency"] page:[arguments[@"page"] intValue] offset:[arguments[@"offset"] intValue] asc:[arguments[@"asc"] boolValue] error:&err];
                if (!err) {
                    resultSync(txs);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"hd_wallet_transfer" isEqualToString:call.method]) {
            if (self->_hdWallet){
                NSString *txhash = [self->_hdWallet transfer:arguments[@"from"] to:arguments[@"to"] amount:arguments[@"amount"] error:&err];
                if (!err) {
                    resultSync(txhash);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"hd_wallet_transferToken" isEqualToString:call.method]) {
            if (self->_hdWallet){
                NSString *txhash = [self->_hdWallet transferToken:arguments[@"from"] to:arguments[@"to"] currency:arguments[@"currency"] amount:arguments[@"amount"] error:&err];
                if (!err) {
                    resultSync(txhash);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_epik_newWallet" isEqualToString:call.method]) {
            self->_epikWallet = EPIK_EpikNewWallet(&err);
            if (!err) {
                resultSync(@"");
            }
        }else if ([@"epik_wallet_balance" isEqualToString:call.method]) {
            if (self->_hdWallet){
                NSString *balance = [self->_epikWallet balance:arguments[@"addr"] error:&err];
                if (!err) {
                    resultSync(balance);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_export" isEqualToString:call.method]) {
            if (self->_hdWallet){
                NSString *privateKey = [self->_epikWallet export:arguments[@"addr"] error:&err];
                if (!err) {
                    resultSync(privateKey);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_import" isEqualToString:call.method]) {
            if (self->_hdWallet){
               NSString *addr = [self->_epikWallet import:arguments[@"privateKey"] error:&err];
                if (!err) {
                    resultSync(addr);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_generateKey" isEqualToString:call.method]) {
            if (self->_hdWallet){
                NSString *address = [self->_epikWallet generateKey:arguments[@"t"] seed:[arguments[@"seed"] data] path:arguments[@"path"] error:&err];
                if (!err) {
                    resultSync(address);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_hasAddr" isEqualToString:call.method]) {
            if (self->_hdWallet){
                BOOL has = [self->_epikWallet hasAddr:arguments[@"addr"]];
                if (!err) {
                    resultSync([NSNumber numberWithBool:has]);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_messageList" isEqualToString:call.method]) {
            if (self->_hdWallet){
                NSString *messages = [self->_epikWallet messageList:[arguments[@"toHeight"] intValue] addr:arguments[@"addr"] error:&err];
                if (!err) {
                    resultSync(messages);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_setDefault" isEqualToString:call.method]) {
            if (self->_hdWallet){
                [self->_epikWallet setDefault:arguments[@"addr"] error:&err];
                if (!err) {
                    resultSync(@"");
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_setRPC" isEqualToString:call.method]) {
            if (self->_hdWallet){
                [self->_epikWallet setRPC:arguments[@"url"] token:arguments[@"token"] error:&err];
                if (!err) {
                    resultSync(@"");
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_sign" isEqualToString:call.method]) {
            if (self->_hdWallet){
                NSData *sign = [self->_epikWallet sign:arguments[@"addr"] hash:[arguments[@"hash"] data] error:&err];
                if (!err) {
                    resultSync([FlutterStandardTypedData typedDataWithBytes:sign]);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_send" isEqualToString:call.method]) {
            if (self->_hdWallet){
                NSString *txHash = [self->_epikWallet send:arguments[@"to"] amount:arguments[@"amount"] error:&err];
                if (!err) {
                    resultSync(txHash);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else {
            resultSync(FlutterMethodNotImplemented);
        }
        if (err) {
            resultSync([FlutterError errorWithCode:@"-1" message:[err localizedDescription] details:[err localizedFailureReason]]);
        }
    });
    
}

@end
