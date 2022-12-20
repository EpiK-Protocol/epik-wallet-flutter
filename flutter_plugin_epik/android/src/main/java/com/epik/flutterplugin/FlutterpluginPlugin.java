package com.epik.flutterplugin;

import android.os.Handler;
import android.os.Looper;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import androidx.annotation.NonNull;
import hd.Hd;
import hd.UniswapInfo;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlutterpluginPlugin
 */
public class FlutterpluginPlugin implements FlutterPlugin, MethodCallHandler
{

    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding)
    {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "epikplugin");
        channel.setMethodCallHandler(this);
    }

//    public static void registerWith(Registrar registrar)
//    {
//        final MethodChannel channel = new MethodChannel(registrar.messenger(), "epikplugin");
//        channel.setMethodCallHandler(new FlutterpluginPlugin());
//    }

    hd.Wallet currentHdWallet;
    epik.Wallet currentEpikWallet;
    ExecutorService pool;

    Handler mHandler = new Handler(Looper.getMainLooper());

    /**
     * 在子线程做耗时操作
     */
    private void workInOtherThread(final Runnable run)
    {
        // new Thread(run).start();
        if (pool == null)
            pool = Executors.newCachedThreadPool();
        pool.execute(run);
    }

    /**
     * 在主线程回调结果
     */
    private void reslutSuccessMainThread(final Result result, final Object ret)
    {
        mHandler.post(new Runnable()
        {
            public void run()
            {
                result.success(ret);
            }
        });
    }

    /**
     * 在主线程回调error
     */
    private void reslutErrorMainThread(final Result result, final Exception ex)
    {
        mHandler.post(new Runnable()
        {
            public void run()
            {
                result.error("-1", ex.toString(), "");
            }
        });
    }

    private void reslutNotImplementedMainThread(final Result result)
    {
        mHandler.post(new Runnable()
        {
            public void run()
            {
                result.notImplemented();
            }
        });
    }


    @Override
    public void onMethodCall(@NonNull final MethodCall call, @NonNull final Result result)
    {
        workInOtherThread(new Runnable()
        {
            public void run()
            {
                try
                {
                    System.out.println("onMethodCall : " + call.method + " work in " + Thread.currentThread().getName());
                    Object ret = "";
                    switch (call.method)
                    {
                        case "getPlatformVersion":
                        {
                            ret = "Android " + android.os.Build.VERSION.RELEASE;
                            break;
                        }
                        // hd.HD ------------------------------------------------------------hd.HD
                        case "hd_hd_newFromMnemonic":
                        {
                            hd.Wallet wallet = hd.Hd.newFromMnemonic((String) call.argument("mnemonic"));
                            currentHdWallet = wallet;
                            break;
                        }
                        case "hd_hd_newFromSeed":
                        {
                            hd.Wallet wallet = hd.Hd.newFromSeed((byte[]) call.argument("seed"));
                            currentHdWallet = wallet;
                            break;
                        }
                        case "hd_hd_newMnemonic":
                        {
                            String mnemonic = hd.Hd.newMnemonic((int) call.argument("bits"));
                            ret = mnemonic;
                            break;
                        }
                        case "hd_hd_newSeed":
                        {
                            byte[] seed = hd.Hd.newSeed();
                            ret = seed;
                            break;
                        }
                        case "hd_hd_seedFromMnemonic":
                        {
                            byte[] seed = hd.Hd.seedFromMnemonic((String) call.argument("mnemonic"));
                            ret = seed;
                            break;
                        }
                        // hd.Wallet ------------------------------------------------------------hd.Wallet
                        case "hd_wallet_accounts":
                        {
                            ret = currentHdWallet.accounts();
                            break;
                        }
                        case "hd_wallet_balance":
                        {
                            ret = currentHdWallet.balance((String) call.argument("address"));
                            break;
                        }
                        case "hd_wallet_contains":
                        {
                            ret = currentHdWallet.contains((String) call.argument("address"));
                            break;
                        }
                        case "hd_wallet_derive":
                        {
                            ret = currentHdWallet.derive((String) call.argument("path"), (Boolean) call.argument("pin"));
                            break;
                        }
                        case "hd_wallet_setRPC":
                        {
                            currentHdWallet.setRPC((String) call.argument("url"));
                            break;
                        }
                        case "hd_wallet_signHash":
                        {
                            byte[] signHash = currentHdWallet.signHash((String) call.argument("address"),
                                    (byte[]) call.argument("hash"));
                            ret = signHash;
                            break;
                        }
                        case "hd_wallet_signText":
                        {
                            byte[] signText = currentHdWallet.signText((String) call.argument("address"),
                                    (String) call.argument("text"));
                            ret = signText;
                            break;
                        }
                        case "hd_wallet_tokenBalance":
                        {
                            String tokenBalance = currentHdWallet.tokenBalance((String) call.argument("address"),
                                    (String) call.argument("currency"));
                            ret = tokenBalance;
                            break;
                        }
                        case "hd_wallet_transactions":
                        {
                            String address = call.argument("address");
                            String currency = call.argument("currency");
                            long page = (int) call.argument("page");
                            long offset = (int) call.argument("offset");
                            boolean asc = call.argument("asc");
                            ret = currentHdWallet.transactions(address, currency, page, offset, asc);
                            break;
                        }
                        case "hd_wallet_transfer":
                        {
                            String from = call.argument("from");
                            String to = call.argument("to");
                            String amount = call.argument("amount");
                            ret = currentHdWallet.transfer(from, to, amount);
                            break;
                        }
                        case "hd_wallet_transferToken":
                        {
                            String from = call.argument("from");
                            String to = call.argument("to");
                            String currency = call.argument("currency");
                            String amount = call.argument("amount");
                            ret = currentHdWallet.transferToken(from, to, currency, amount);
                            break;
                        }
                        case "hd_wallet_uniswapinfo":
                        {
                            String address = call.argument("address");
                            UniswapInfo uniswapinfo = currentHdWallet.uniswapInfo(address);
                            Map<String, Object> map = new HashMap();
                            map.put("USDT", uniswapinfo.getUSDT());
                            map.put("EPK", uniswapinfo.getEPK());
                            map.put("Share", uniswapinfo.getShare());
                            map.put("LastBlockTime", uniswapinfo.getLastBlockTime());
                            map.put("UNI", uniswapinfo.getUNI());
                            ret = map;
                            break;
                        }
                        case "hd_wallet_uniswapgetamountsout":
                        {
                            String tokenA = call.argument("tokenA");
                            String tokenB = call.argument("tokenB");
                            String amountIn = call.argument("amountIn");
                            hd.Amounts amounts = currentHdWallet.uniswapGetAmountsOut(tokenA, tokenB, amountIn);
                            Map<String, Object> map = new HashMap();
                            map.put("AmountIn", amounts.getAmountIn());
                            map.put("AmountOut", amounts.getAmountOut());
                            ret = map;
                            break;
                        }
                        case "hd_wallet_uniswapexacttokenfortokens":
                        {
                            String address = call.argument("address");
                            String tokenA = call.argument("tokenA");
                            String tokenB = call.argument("tokenB");
                            String amountIn = call.argument("amountIn");
                            String amountOutMin = call.argument("amountOutMin");
                            String deadline = call.argument("deadline");
                            ret = currentHdWallet.uniswapExactTokenForTokens(address, tokenA, tokenB, amountIn, amountOutMin, deadline);
                            break;
                        }
                        case "hd_wallet_uniswapaddliquidity":
                        {
                            String address = call.argument("address");
                            String tokenA = call.argument("tokenA");
                            String tokenB = call.argument("tokenB");
                            String amountADesired = call.argument("amountADesired");
                            String amountBDesired = call.argument("amountBDesired");
                            String amountAMin = call.argument("amountAMin");
                            String amountBMin = call.argument("amountBMin");
                            String deadline = call.argument("deadline");
                            ret = currentHdWallet.uniswapAddLiquidity(address, tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, deadline);
                            break;
                        }
                        case "hd_wallet_uniswapremoveliquidity":
                        {
                            String address = call.argument("address");
                            String tokenA = call.argument("tokenA");
                            String tokenB = call.argument("tokenB");
                            String liquidity = call.argument("liquidity");
                            String amountAMin = call.argument("amountAMin");
                            String amountBMin = call.argument("amountBMin");
                            String deadline = call.argument("deadline");
                            ret = currentHdWallet.uniswapRemoveLiquidity(address, tokenA, tokenB, liquidity, amountAMin, amountBMin, deadline);
                            break;
                        }
                        case "hd_wallet_suggestgas":
                        {
                            ret = currentHdWallet.suggestGas();
                            break;
                        }
                        case "hd_wallet_suggestgasprice":
                        {
                            ret = currentHdWallet.suggestGasPrice();
                            break;
                        }
                        // epik.Epik ------------------------------------------------------------epik.Epik
                        case "epik_epik_newWallet":
                        {
                            currentEpikWallet = epik.Epik.newWallet();
                            break;
                        }
                        // epik.Wallet ------------------------------------------------------------epik.Wallet
                        case "epik_wallet_balance":
                        {
                            ret = currentEpikWallet.balance((String) call.argument("addr"));
                            break;
                        }
                        case "epik_wallet_export":
                        {
                            ret = currentEpikWallet.export((String) call.argument("addr"));
                            break;
                        }
                        case "epik_wallet_generateKey":
                        {
                            ret = currentEpikWallet.generateKey((String) call.argument("t"), (byte[]) call.argument("seed"), (String) call.argument("path"));
                            break;
                        }
                        case "epik_wallet_hasAddr":
                        {
                            ret = currentEpikWallet.hasAddr((String) call.argument("addr"));
                            break;
                        }
                        case "epik_wallet_import":
                        {
                            ret = currentEpikWallet.import_((String) call.argument("privateKey"));
                            break;
                        }
                        // Deprecated  2021-03-25 从SDK中删除
                        // case "epik_wallet_messageList":
                        // {
                        //   ret = currentEpikWallet.messageList((int) call.argument("toHeight"),(String) call.argument("addr"));
                        //   break;
                        // }
                        case "epik_wallet_send":
                        {
                            ret = currentEpikWallet.send((String) call.argument("to"),
                                    (String) call.argument("amount"));
                            break;
                        }
                        case "epik_wallet_setDefault":
                        {
                            currentEpikWallet.setDefault((String) call.argument("addr"));
                            break;
                        }
                        case "epik_wallet_setRPC":
                        {
                            currentEpikWallet.setRPC((String) call.argument("url"), (String) call.argument("token"));
                            break;
                        }
                        case "epik_wallet_sign":
                        {
                            ret = currentEpikWallet.sign((String) call.argument("addr"), (byte[]) call.argument("hash"));
                            break;
                        }
                        // 2021-03-25 新增  epik  ------------------------------
                        case "epik_wallet_createExpert":
                        {
                            // 创建领域专家 applicationHash
                            ret = currentEpikWallet.createExpert((String) call.argument("applicationHash"));
                            break;
                        }
                        case "epik_wallet_expertInfo":
                        {
                            // 专家详情
                            ret = currentEpikWallet.expertInfo((String) call.argument("addr"));
                            break;
                        }
                        case "epik_wallet_expertList":
                        {
                            // 专家列表
                            ret = currentEpikWallet.expertList();
                            break;
                        }
                        case "epik_wallet_expertNominate":
                        {
                            //20220823新增  专家提名通过 自己给别人通过申请
                            ret = currentEpikWallet.expertNominate((String) call.argument("selfId"),(String) call.argument("targetId"));
                            break;
                        }
                        case "epik_wallet_messageReceipt":
                        {
                            // 消息回执
                            ret = currentEpikWallet.messageReceipt((String) call.argument("cidStr"));
                            break;
                        }
                        case "epik_wallet_voteRescind":
                        {
                            // 投票撤销
                            ret = currentEpikWallet.voteRescind((String) call.argument("candidate"), (String) call.argument("amount"));
                            break;
                        }
                        case "epik_wallet_voteSend":
                        {
                            // 投票
                            ret = currentEpikWallet.voteSend((String) call.argument("candidate"), (String) call.argument("amount"));
                            break;
                        }
                        case "epik_wallet_voteWithdraw":
                        {
                            // 投票提现
                            ret = currentEpikWallet.voteWithdraw((String) call.argument("to"));
                            break;
                        }
                        case "epik_wallet_voterInfo":
                        {
                            // 投票信息
                            ret = currentEpikWallet.voterInfo((String) call.argument("addr"));
                            break;
                        }
                        // 2021-04-19 新增  epik  ------------------------------
                        case "epik_wallet_minerInfo":
                        {
                            // 矿机信息
                            ret = currentEpikWallet.minerInfo((String) call.argument("minerID"));
                            break;
                        }
                        case "epik_wallet_minerPledgeAdd":
                        {
                            // 矿机 基础抵押 添加
                            ret = currentEpikWallet.minerPledgeAdd((String) call.argument("toMinerID"), (String) call.argument("amount"));
                            break;
                        }
                        case "epik_wallet_minerPledgeWithdraw":
                        {
                            // 矿机 基础抵押 撤回
                            ret = currentEpikWallet.minerPledgeWithdraw((String) call.argument("toMinerID"), (String) call.argument("amount"));
                            break;
                        }
                        case "epik_wallet_retrievePledgeAdd":
                        {
                            // 矿机 访问抵押 添加
                            ret = currentEpikWallet.retrievePledgeAdd((String) call.argument("target"), (String) call.argument("toMinerID"), (String) call.argument("amount"));
                            break;
                        }
                        case "epik_wallet_retrievePledgeApplyWithdraw":
                        {
                            // 矿机 访问抵押 申请撤回  第一步 三天后可以执行第二部
                            ret = currentEpikWallet.retrievePledgeApplyWithdraw((String) call.argument("target"), (String) call.argument("amount"));
                            break;
                        }
                        case "epik_wallet_retrievePledgeWithdraw":
                        {
                            // 矿机 访问抵押 撤回 第二步 //20210624删除toMinerID
                            ret = currentEpikWallet.retrievePledgeWithdraw((String) call.argument("amount"));
                            break;
                        }
                        case "epik_wallet_retrievePledgeBind":
                        {
                            // 矿机 访问抵押 绑定
                            ret = currentEpikWallet.retrievePledgeBind((String) call.argument("miner"), (String) call.argument("amount"));
                            break;
                        }
                        case "epik_wallet_retrievePledgeUnBind":
                        {
                            // 矿机 访问抵押 解绑
                            ret = currentEpikWallet.retrievePledgeUnBind((String) call.argument("miner"), (String) call.argument("amount"));
                            break;
                        }
                        // 2021-03-25 新增  hd  ------------------------------
                        case "hd_wallet_accelerateTx":
                        {
                            // AccelerateTx 加速交易
                            String srcTxHash = call.argument("srcTxHash");
                            double gasRate = (double) call.argument("gasRate");
                            ret = currentHdWallet.accelerateTx(srcTxHash, gasRate);
                            break;
                        }
                        case "hd_wallet_cancelTx":
                        {
                            // CancelTx 取消交易
                            String srcTxHash = call.argument("srcTxHash");
                            ret = currentHdWallet.cancelTx(srcTxHash);
                            break;
                        }
                        case "hd_wallet_receipt":
                        {
                            // receipt
                            String txHash = call.argument("txHash");
                            ret = currentHdWallet.receipt(txHash);
                            break;
                        }
                        case "hd_wallet_export":
                        {
                            // hd钱包导出私钥
                            ret = currentHdWallet.export((String) call.argument("addr"));
                            break;
                        }
                        ///----- 20210624 epik 新增
                        case "epik_wallet_coinbaseInfo":
                        {
                            //epik钱包coinbase信息
                            ret = currentEpikWallet.coinbaseInfo((String) call.argument("addr"));
                            break;
                        }
                        case "epik_wallet_coinbaseWithdraw":
                        {
                            //coinbase提取
                            ret = currentEpikWallet.coinbaseWithdraw();
                            break;
                        }
                        case "epik_wallet_minerPledgeOneClick":
                        {
                            //矿机批量抵押
                            currentEpikWallet.minerPledgeOneClick((String) call.argument("minerStr"));
                            ret = "ok";
                            break;
                        }
                        case "epik_wallet_gasEstimateGasLimit":
                        {
                            // 查询epik手续费  actor ：transfer交易
                            ret = currentEpikWallet.gasEstimateGasLimit((String) call.argument("actor"));
                            break;
                        }
                        ///----- 20210705 epik 新增
                        case "epik_wallet_signAndSendMessage":
                        {
                            //String signAndSendMessage(String addr, String message)
                            ret = currentEpikWallet.signAndSendMessage((String) call.argument("addr"), (String) call.argument("message"));
                            break;
                        }
                        case "epik_wallet_signCID":
                        {
                            //byte[] signCID(String addr, String cidStr)
                            ret = currentEpikWallet.signCID((String) call.argument("addr"), (String) call.argument("cidStr"));
                            break;
                        }
                        ///----- 20210712 ht 新增
                        case "hd_setDebug":
                        {
                            //设置以太网络dev环境
                            Hd.setDebug((Boolean) call.argument("debug"));
                            ret = "";
                            break;
                        }
                        ///----- 20210923 epik 新增
                        case "epik_wallet_minerPledgeApplyWithdraw":
                        {
                            // 矿机基础抵押 申请提现撤回 返回cid
                            // String minerPledgeApplyWithdraw(String minerID)
                            ret = currentEpikWallet.minerPledgeApplyWithdraw((String) call.argument("minerID"));
                            break;
                        }
                        case "epik_wallet_minerPledgeTransfer":
                        {
                            // 矿机基础抵押 转移抵押 转移到其他节点 返回cid
                            // minerPledgeTransfer(String fromMinerID, String toMinerID) 废弃
                            // minerPledgeTransfer(String fromMinerID, String toMinerID, String amount)  2021-10-09修改
                            ret = currentEpikWallet.minerPledgeTransfer((String) call.argument("fromMinerID"),(String) call.argument("toMinerID"),(String) call.argument("amount"));
                            break;
                        }
                        case "epik_wallet_minerPledgeApplyWithdrawOneClick":{
                            //矿机批量申请赎回
                            currentEpikWallet.minerPledgeApplyWithdrawOneClick((String) call.argument("minerStr"));
                            ret = "ok";
                            break;
                        }
                        case "epik_wallet_minerPledgeWithdrawOneClick":{
                            //矿机批量赎回提现
                            currentEpikWallet.minerPledgeWithdrawOneClick((String) call.argument("minerStr"));
                            ret = "ok";
                            break;
                        }
                        case "epik_wallet_retrievePledgeState":{
                            // 流量抵押状态 String retrievePledgeState(String addr) throws Exception;
                            ret = currentEpikWallet.retrievePledgeState((String) call.argument("addr"));
                            break;
                        }
                        default:
                        {
                            reslutNotImplementedMainThread(result);
                            return;
                        }
                    }

                    reslutSuccessMainThread(result, ret);
                } catch (Exception ex)
                {
                    ex.printStackTrace();
                    /// 通道返回error
                    reslutErrorMainThread(result, ex);
                }
            }
        });
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding)
    {
        channel.setMethodCallHandler(null);
    }
}
