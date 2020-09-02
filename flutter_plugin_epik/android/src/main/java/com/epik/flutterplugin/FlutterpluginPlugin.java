package com.epik.flutterplugin;

import java.util.HashMap;
import java.util.Map;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterpluginPlugin */
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

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result)
    {
        try
        {
            switch (call.method)
            {
            case "getPlatformVersion" :
            {
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            }
            // hd.HD ------------------------------------------------------------hd.HD
            case "hd_hd_newFromMnemonic" :
            {
                hd.Wallet wallet = hd.Hd.newFromMnemonic((String) call.argument("mnemonic"));
                currentHdWallet = wallet;
                result.success("");
                break;
            }
            case "hd_hd_newFromSeed" :
            {
                hd.Wallet wallet = hd.Hd.newFromSeed((byte[]) call.argument("seed"));
                currentHdWallet = wallet;
                result.success("");
                break;
            }
            case "hd_hd_newMnemonic" :
            {
                String mnemonic = hd.Hd.newMnemonic((int) call.argument("bits"));
                result.success(mnemonic);
                break;
            }
            case "hd_hd_newSeed" :
            {
                byte[] seed = hd.Hd.newSeed();
                result.success(seed);
                break;
            }
            case "hd_hd_seedFromMnemonic" :
            {
                byte[] seed = hd.Hd.seedFromMnemonic((String) call.argument("mnemonic"));
                result.success(seed);
                break;
            }
            // hd.Wallet ------------------------------------------------------------hd.Wallet
            case "hd_wallet_balance" :
            {
                String balance = currentHdWallet.balance((String) call.argument("address"));
                result.success(balance);
                break;
            }
            case "hd_wallet_contains" :
            {
                boolean contains = currentHdWallet.contains((String) call.argument("address"));
                result.success(contains);
                break;
            }
            case "hd_wallet_derive" :
            {
                String derive = currentHdWallet.derive((String) call.argument("path"), (Boolean) call.argument("pin"));
                result.success(derive);
                break;
            }
            case "hd_wallet_setRPC" :
            {
                currentHdWallet.setRPC((String) call.argument("url"));
                result.success("");
                break;
            }
            case "hd_wallet_signHash" :
            {
                byte[] signHash = currentHdWallet.signHash((String) call.argument("address"),
                        (byte[]) call.argument("hash"));
                result.success(signHash);
                break;
            }
            case "hd_wallet_signText" :
            {
                byte[] signText = currentHdWallet.signText((String) call.argument("address"),
                        (String) call.argument("text"));
                result.success(signText);
                break;
            }
            case "hd_wallet_tokenBalance" :
            {
                String tokenBalance = currentHdWallet.tokenBalance((String) call.argument("address"),
                        (String) call.argument("p1"));
                result.success(tokenBalance);
                break;
            }
            case "hd_wallet_transactions" :
            {
                String address = call.argument("address");
                String p1 = call.argument("p1");
                long page = call.argument("page");
                long offset = call.argument("offset");
                boolean asc = call.argument("asc");
                String ret = currentHdWallet.transactions(address, p1, page, offset, asc);
                result.success(ret);
                break;
            }
            case "hd_wallet_transfer" :
            {
                String from = call.argument("from");
                String to = call.argument("to");
                String amount = call.argument("amount");
                String ret = currentHdWallet.transfer(from, to, amount);
                result.success(ret);
                break;
            }
            case "hd_wallet_transferToken" :
            {
                String from = call.argument("from");
                String to = call.argument("to");
                String p2 = call.argument("p2");
                String amount = call.argument("amount");
                String ret = currentHdWallet.transferToken(from, to, p2, amount);
                result.success(ret);
                break;
            }
            // epik.Epik ------------------------------------------------------------epik.Epik
            case "epik_epik_newWallet" :
            {
                currentEpikWallet = epik.Epik.newWallet();
                result.success("");
                break;
            }
            // epik.Wallet ------------------------------------------------------------epik.Wallet
            case "epik_wallet_balance" :
            {
                String ret = currentEpikWallet.balance((String) call.argument("addr"));
                result.success(ret);
                break;
            }
            case "epik_wallet_export" :
            {
                epik.PrivateKey pkey = currentEpikWallet.export((String) call.argument("addr"));
                Map<String, String> retmap = new HashMap();
                retmap.put("keyType", pkey.getKeyType());
                retmap.put("privateKey", pkey.getPrivateKey());
                result.success(retmap);
                break;
            }
            case "epik_wallet_generateKey" :
            {
                String ret = currentEpikWallet.generateKey((String) call.argument("t"), (byte[]) call.argument("seed"));
                result.success(ret);
                break;
            }
            case "epik_wallet_hasAddr" :
            {
                boolean ret = currentEpikWallet.hasAddr((String) call.argument("addr"));
                result.success(ret);
                break;
            }
            case "epik_wallet_messageList" :
            {
                String ret = currentEpikWallet.messageList((int) call.argument("toHeight"),
                        (String) call.argument("addr"));
                result.success(ret);
                break;
            }
            case "epik_wallet_setDefault" :
            {
                currentEpikWallet.setDefault((String) call.argument("addr"));
                result.success("");
                break;
            }
            case "epik_wallet_setRPC" :
            {
                currentEpikWallet.setRPC((String) call.argument("url"), (String) call.argument("token"));
                result.success("");
                break;
            }
            case "epik_wallet_sign" :
            {
                byte[] ret = currentEpikWallet.sign((String) call.argument("addr"), (byte[]) call.argument("hash"));
                result.success(ret);
                break;
            }
            default:
            {
                result.notImplemented();
                break;
            }
            }
        } catch (Exception ex)
        {
            ex.printStackTrace();

            /// 通道返回error
            String error = ex.toString();
            result.error("-1", error, "");
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding)
    {
        channel.setMethodCallHandler(null);
    }
}
