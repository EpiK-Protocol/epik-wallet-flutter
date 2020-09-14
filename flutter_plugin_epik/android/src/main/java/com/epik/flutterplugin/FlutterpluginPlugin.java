package com.epik.flutterplugin;

import android.os.Handler;
import android.os.Looper;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import androidx.annotation.NonNull;
import hd.UniswapInfo;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterpluginPlugin
 */
public class FlutterpluginPlugin implements FlutterPlugin, MethodCallHandler
{

    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding)
    {
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "epikplugin");
        channel.setMethodCallHandler(this);
    }

    public static void registerWith(Registrar registrar)
    {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "epikplugin");
        channel.setMethodCallHandler(new FlutterpluginPlugin());
    }

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
                        case "epik_wallet_messageList":
                        {
                            ret = currentEpikWallet.messageList((int) call.argument("toHeight"),
                                    (String) call.argument("addr"));
                            break;
                        }
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
