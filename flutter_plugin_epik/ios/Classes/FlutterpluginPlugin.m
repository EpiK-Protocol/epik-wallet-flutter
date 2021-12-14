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
            NSString *mnemonic = EPIK_HdNewMnemonic([arguments[@"bits"] longValue], &err);
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
            if (!err){
                FlutterStandardTypedData *data = [FlutterStandardTypedData typedDataWithBytes:seed];
                resultSync(data);
            }
        }else if ([@"hd_hd_seedFromMnemonic" isEqualToString:call.method]) {
            NSData *seed = EPIK_HdSeedFromMnemonic(arguments[@"mnemonic"], &err);
            if (!err){
                FlutterStandardTypedData *data = [FlutterStandardTypedData typedDataWithBytes:seed];
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
                if (!err) {
                    FlutterStandardTypedData *data = [FlutterStandardTypedData typedDataWithBytes:sign];
                    resultSync(data);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"hd_wallet_signText" isEqualToString:call.method]) {
            if (self->_hdWallet){
                NSData *sign = [self->_hdWallet signText:arguments[@"address"] text:arguments[@"text"] error:&err];
                if (!err) {
                    FlutterStandardTypedData *data = [FlutterStandardTypedData typedDataWithBytes:sign];
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
        }else if ([@"hd_wallet_suggestgas" isEqualToString:call.method]) {
            if (self->_hdWallet){
                NSString *gas = [self->_hdWallet suggestGas:&err];
                if (!err) {
                    resultSync(gas);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"hd_wallet_suggestgasprice" isEqualToString:call.method]) {
            if (self->_hdWallet){
                NSString *price = [self->_hdWallet suggestGasPrice:&err];
                if (!err) {
                    resultSync(price);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"hd_wallet_transactions" isEqualToString:call.method]) {
            if (self->_hdWallet){
                NSString *txs = [self->_hdWallet transactions:arguments[@"address"] currency:arguments[@"currency"] page:[arguments[@"page"] longLongValue] offset:[arguments[@"offset"] longLongValue] asc:[arguments[@"asc"] boolValue] error:&err];
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
        }else if ([@"hd_wallet_uniswapinfo" isEqualToString:call.method]) {
            if (self->_hdWallet){
                EPIK_HdUniswapInfo *info = [self->_hdWallet uniswapInfo:arguments[@"address"] error:&err];
                if (!err) {
                    resultSync(@{@"USDT":info.usdt,@"EPK":info.epk,@"Share":info.share,@"LastBlockTime":[NSNumber numberWithLong:(info.lastBlockTime)],@"UNI":info.uni});
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"hd_wallet_uniswapgetamountsout" isEqualToString:call.method]) {
            if (self->_hdWallet){
                EPIK_HdAmounts *amount = [self->_hdWallet uniswapGetAmountsOut:arguments[@"tokenA"] tokenB:arguments[@"tokenB"] amountIn:arguments[@"amountIn"] error:&err];
                if (!err) {
                    resultSync(@{@"AmountIn":amount.amountIn,@"AmountOut":amount.amountOut});
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"hd_wallet_uniswapexacttokenfortokens" isEqualToString:call.method]) {
            if (self->_hdWallet){
                NSString *txhash = [self->_hdWallet uniswapExactTokenForTokens:arguments[@"address"] tokenA:arguments[@"tokenA"] tokenB:arguments[@"tokenB"] amountIn:arguments[@"amountIn"] amountOutMin:arguments[@"amountOutMin"] deadline:arguments[@"deadline"] error:&err];
                if (!err) {
                    resultSync(txhash);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"hd_wallet_uniswapaddliquidity" isEqualToString:call.method]) {
            if (self->_hdWallet){
                NSString *txhash = [self->_hdWallet uniswapAddLiquidity:arguments[@"address"] tokenA:arguments[@"tokenA"] tokenB:arguments[@"tokenB"] amountADesired:arguments[@"amountADesired"] amountBDesired:arguments[@"amountBDesired"] amountAMin:arguments[@"amountAMin"] amountBMin:arguments[@"amountBMin"] deadline:arguments[@"deadline"] error:&err];
                if (!err) {
                    resultSync(txhash);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"hd_wallet_uniswapremoveliquidity" isEqualToString:call.method]) {
            if (self->_hdWallet){
                NSString *txhash = [self->_hdWallet uniswapRemoveLiquidity:arguments[@"address"] tokenA:arguments[@"tokenA"] tokenB:arguments[@"tokenB"] liquidity:arguments[@"liquidity"] amountAMin:arguments[@"amountAMin"] amountBMin:arguments[@"amountBMin"] deadline:arguments[@"deadline"] error:&err];
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
            if (self->_epikWallet){
                NSString *balance = [self->_epikWallet balance:arguments[@"addr"] error:&err];
                if (!err) {
                    resultSync(balance);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_export" isEqualToString:call.method]) {
            if (self->_epikWallet){
                NSString *privateKey = [self->_epikWallet export:arguments[@"addr"] error:&err];
                if (!err) {
                    resultSync(privateKey);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_import" isEqualToString:call.method]) {
            if (self->_epikWallet){
               NSString *addr = [self->_epikWallet import:arguments[@"privateKey"] error:&err];
                if (!err) {
                    resultSync(addr);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_generateKey" isEqualToString:call.method]) {
            if (self->_epikWallet){
                NSString *address = [self->_epikWallet generateKey:arguments[@"t"] seed:[arguments[@"seed"] data] path:arguments[@"path"] error:&err];
                if (!err) {
                    resultSync(address);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_hasAddr" isEqualToString:call.method]) {
            if (self->_epikWallet){
                BOOL has = [self->_epikWallet hasAddr:arguments[@"addr"]];
                if (!err) {
                    resultSync([NSNumber numberWithBool:has]);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }
//        Deprecated  2021-03-25
//        else if ([@"epik_wallet_messageList" isEqualToString:call.method]) {
//            if (self->_hdWallet){
//                NSString *messages = [self->_epikWallet messageList:[arguments[@"toHeight"] intValue] addr:arguments[@"addr"] error:&err];
//                if (!err) {
//                    resultSync(messages);
//                }
//            }else{
//                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
//            }
//        }
        else if ([@"epik_wallet_setDefault" isEqualToString:call.method]) {
            if (self->_epikWallet){
                [self->_epikWallet setDefault:arguments[@"addr"] error:&err];
                if (!err) {
                    resultSync(@"");
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_setRPC" isEqualToString:call.method]) {
            if (self->_epikWallet){
                [self->_epikWallet setRPC:arguments[@"url"] token:arguments[@"token"] error:&err];
                if (!err) {
                    resultSync(@"");
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_sign" isEqualToString:call.method]) {
            if (self->_epikWallet){
                NSData *sign = [self->_epikWallet sign:arguments[@"addr"] hash:[arguments[@"hash"] data] error:&err];
                if (!err) {
                    resultSync([FlutterStandardTypedData typedDataWithBytes:sign]);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_send" isEqualToString:call.method]) {
            if (self->_epikWallet){
                NSString *txHash = [self->_epikWallet send:arguments[@"to"] amount:arguments[@"amount"] error:&err];
                if (!err) {
                    resultSync(txHash);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }
        // 2021-03-25 新增  epik  ------------------------------
        else if ([@"epik_wallet_createExpert" isEqualToString:call.method]) {
            // 创建领域专家 applicationHash
            if (self->_epikWallet){
                NSString *ret = [self->_epikWallet createExpert:arguments[@"applicationHash"] error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_expertInfo" isEqualToString:call.method]) {
            // 专家详情
            if (self->_epikWallet){
                NSString *ret = [self->_epikWallet expertInfo:arguments[@"addr"] error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_expertList" isEqualToString:call.method]) {
            // 专家列表
            if (self->_epikWallet){
                NSString *ret = [self->_epikWallet expertList:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_messageReceipt" isEqualToString:call.method]) {
            // 消息回执
            if (self->_epikWallet){
                NSString *ret = [self->_epikWallet messageReceipt:arguments[@"cidStr"] error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_voteRescind" isEqualToString:call.method]) {
            // 投票撤销
            if (self->_epikWallet){
                NSString *ret = [self->_epikWallet voteRescind:arguments[@"candidate"] amount:arguments[@"amount"] error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_voteSend" isEqualToString:call.method]) {
            // 投票
            if (self->_epikWallet){
                NSString *ret = [self->_epikWallet voteSend:arguments[@"candidate"] amount:arguments[@"amount"] error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_voteWithdraw" isEqualToString:call.method]) {
            // 投票提现
            if (self->_epikWallet){
                NSString *ret = [self->_epikWallet voteWithdraw:arguments[@"to"] error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_voterInfo" isEqualToString:call.method]) {
            // 投票信息
            if (self->_epikWallet){
                NSString *ret = [self->_epikWallet voterInfo:arguments[@"addr"] error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }
        // 2021-04-19 新增  epik  ------------------------------
        else if ([@"epik_wallet_minerInfo" isEqualToString:call.method]) {
            // 矿机信息
            if (self->_epikWallet){
                NSString *ret = [self->_epikWallet minerInfo:arguments[@"minerID"] error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_minerPledgeAdd" isEqualToString:call.method]) {
            // 矿机 基础抵押 添加
            if (self->_epikWallet){
                NSString *ret = [self->_epikWallet minerPledgeAdd:arguments[@"toMinerID"] amount:arguments[@"amount"] error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_minerPledgeWithdraw" isEqualToString:call.method]) {
            // 矿机 基础抵押 撤回
            if (self->_epikWallet){
                NSString *ret = [self->_epikWallet minerPledgeWithdraw:arguments[@"toMinerID"] amount:arguments[@"amount"] error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_retrievePledgeAdd" isEqualToString:call.method]) {
            // 矿机 访问抵押 添加
            if (self->_epikWallet){
                NSString *ret = [self->_epikWallet retrievePledgeAdd:arguments[@"target"] miner:arguments[@"toMinerID"] amount:arguments[@"amount"] error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_retrievePledgeApplyWithdraw" isEqualToString:call.method]) {
            // 矿机 访问抵押 申请撤回  第一步 三天后可以执行第二部 minerid 改成owner
            if (self->_epikWallet){
                NSString *ret = [self->_epikWallet retrievePledgeApplyWithdraw:arguments[@"target"] amount:arguments[@"amount"] error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_retrievePledgeWithdraw" isEqualToString:call.method]) {
            // 矿机 访问抵押 撤回 第二步
            if (self->_epikWallet){
                // NSString *ret = [self->_epikWallet retrievePledgeWithdraw:arguments[@"toMinerID"] amount:arguments[@"amount"] error:&err];
                // 20210624删除toMinerID
                NSString *ret = [self->_epikWallet retrievePledgeWithdraw:arguments[@"amount"] error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_retrievePledgeBind" isEqualToString:call.method]) {
            // 矿机 访问抵押 绑定
            if (self->_epikWallet){
                NSString *ret = [self->_epikWallet retrievePledgeBind:arguments[@"miner"] amount:arguments[@"amount"] error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"epik_wallet_retrievePledgeUnBind" isEqualToString:call.method]) {
            // 矿机 访问抵押 解绑
            if (self->_epikWallet){
                NSString *ret = [self->_epikWallet retrievePledgeUnBind:arguments[@"miner"] amount:arguments[@"amount"] error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }
        // 2021-03-25 新增  hd  ------------------------------
        else if ([@"hd_wallet_accelerateTx" isEqualToString:call.method]) {
            // AccelerateTx 加速交易
            if (self->_hdWallet){
                NSString *ret = [self->_hdWallet accelerateTx:arguments[@"srcTxHash"] gasRate:[arguments[@"gasRate"] doubleValue] error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"hd_wallet_cancelTx" isEqualToString:call.method]) {
            // CancelTx 取消交易
            if (self->_hdWallet){
                NSString *ret = [self->_hdWallet cancelTx:arguments[@"srcTxHash"] error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"hd_wallet_receipt" isEqualToString:call.method]) {
            // receipt
            if (self->_hdWallet){
                NSString *ret = [self->_hdWallet receipt:arguments[@"txHash"] error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }else if ([@"hd_wallet_export" isEqualToString:call.method]) {
            // hd钱包导出私钥
            if (self->_hdWallet){
                NSString *ret = [self->_hdWallet export:arguments[@"addr"] error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"hdWallet is Nil"}];
            }
        }
        ///----- 20210624 epik 新增
        else if ([@"epik_wallet_coinbaseInfo" isEqualToString:call.method]) {
            //epik钱包coinbase信息
            if (self->_epikWallet){
                NSString *ret = [self->_epikWallet coinbaseInfo:arguments[@"addr"]  error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"epikWallet is Nil"}];
            }
        }else if ([@"epik_wallet_coinbaseWithdraw" isEqualToString:call.method]) {
            //coinbase提取
            if (self->_epikWallet){
                NSString *ret = [self->_epikWallet coinbaseWithdraw: &err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"epikWallet is Nil"}];
            }
        }else if ([@"epik_wallet_minerPledgeOneClick" isEqualToString:call.method]) {
            //矿机批量抵押
            if (self->_epikWallet){
                [self->_epikWallet minerPledgeOneClick:arguments[@"minerStr"] error: &err];
                NSString *ret = @"ok";
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"epikWallet is Nil"}];
            }
        }else if ([@"epik_wallet_gasEstimateGasLimit" isEqualToString:call.method]) {
            // 查询epik手续费  actor ：transfer交易
            if (self->_epikWallet){
                NSString *ret = [self->_epikWallet gasEstimateGasLimit:arguments[@"actor"] error: &err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"epikWallet is Nil"}];
            }
        }
        ///----- 20210705 epik 新增
        else if ([@"epik_wallet_signAndSendMessage" isEqualToString:call.method]) {
            //String signAndSendMessage(String addr, String message)
            if (self->_epikWallet){
                NSString *cid = [self->_epikWallet signAndSendMessage:arguments[@"addr"] message:arguments[@"message"] error:&err];
                if (!err) {
                    resultSync(cid);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"epikWallet is Nil"}];
            }
        }else if ([@"epik_wallet_signCID" isEqualToString:call.method]) {
            //byte[] signCID(String addr, String message)
            if (self->_epikWallet){
                NSData *ret = [self->_epikWallet signCID:arguments[@"addr"] cidStr:arguments[@"cidStr"] error:&err];
                if (!err) {
                    resultSync([FlutterStandardTypedData typedDataWithBytes:ret]);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"epikWallet is Nil"}];
            }
        }
        ///----- 20210712 ht 新增
        else if ([@"hd_setDebug" isEqualToString:call.method]) {
            //Hd.setDebug((Boolean) call.argument("debug"));
            EPIK_HdSetDebug([arguments[@"debug"]boolValue]);
            resultSync(@"");
        }
        ///----- 20210923 epik 新增
        else if([@"epik_wallet_minerPledgeApplyWithdraw" isEqualToString:call.method]){
            // 矿机基础抵押 申请提现撤回 返回cid
            if (self->_epikWallet){
                NSString *ret = [self->_epikWallet minerPledgeApplyWithdraw:arguments[@"minerID"]  error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"epikWallet is Nil"}];
            }
        }else if([@"epik_wallet_minerPledgeTransfer" isEqualToString:call.method]){
            // 矿机基础抵押 转移抵押 转移到其他节点 返回cid
            // minerPledgeTransfer(String fromMinerID, String toMinerID, String amount)  2021-10-09修改
            if (self->_epikWallet){
                NSString *ret = [self->_epikWallet minerPledgeTransfer:arguments[@"fromMinerID"] toMinerID:arguments[@"toMinerID"] amount:arguments[@"amount"] error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"epikWallet is Nil"}];
            }
        }else if ([@"epik_wallet_minerPledgeApplyWithdrawOneClick" isEqualToString:call.method]) {
            //矿机批量申请赎回
            if (self->_epikWallet){
                [self->_epikWallet minerPledgeApplyWithdrawOneClick:arguments[@"minerStr"] error: &err];
                NSString *ret = @"ok";
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"epikWallet is Nil"}];
            }
        }else if ([@"epik_wallet_minerPledgeWithdrawOneClick" isEqualToString:call.method]) {
            //矿机批量赎回提现
            if (self->_epikWallet){
                [self->_epikWallet minerPledgeWithdrawOneClick:arguments[@"minerStr"] error: &err];
                NSString *ret = @"ok";
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"epikWallet is Nil"}];
            }
        }else if([@"epik_wallet_retrievePledgeState" isEqualToString:call.method]){
            // 单独请求流量状态
            if (self->_epikWallet){
                NSString *ret = [self->_epikWallet retrievePledgeState:arguments[@"addr"] error:&err];
                if (!err) {
                    resultSync(ret);
                }
            }else{
                err = [NSError errorWithDomain:@"epik" code:-1 userInfo:@{@"Error reason":@"epikWallet is Nil"}];
            }
        }
        else {
            resultSync(FlutterMethodNotImplemented);
        }
        if (err) {
            resultSync([FlutterError errorWithCode:@"-1" message:[err localizedDescription] details:[err localizedFailureReason]]);
        }
    });
    
}

@end
