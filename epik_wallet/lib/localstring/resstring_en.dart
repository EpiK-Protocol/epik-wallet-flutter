import 'package:epikwallet/localstring/resstringid.dart';

// 英文字符表
Map<RSID, String> map_en = {
  //base
  RSID.doubleclickquit: "Click again to exit",//"再按一次退出",
  RSID.copied: "Copied to clipboard",//"已复制到剪切板",
  RSID.tip: "Tip",//"提示",
  RSID.confirm: "Confirm",//"确定",
  RSID.cancel: "Cancel",//"取消",
  RSID.last_step: "Last step",//"上一步",
  RSID.next_step: "Next step",//"下一步",
  RSID.isee: "Okay",//"知道了",
  RSID.upgrade_tip: "Update Reminder",//"版本升级提示",
  RSID.upgrade_des: "A new version %s is available.",//"有新版本V",
  RSID.upgrade_des_1: "Need to upgrade Fail to upgrade may affect normal function",//"需要升级\n如不升级可能会影响正常功能",
  RSID.upgrade_des_2: "You can upgrade. Are you upgrading now?",//"可以升级\n是否现在升级?",
  RSID.upgrade_confirm: "Upgrade",//"升级",
  RSID.upgrade_cancel: "Cancel",//"取消",
  RSID.completed: "Completed",//"已完成",
  RSID.request_failed: "Request failed",//"请求失败",
  RSID.request_failed_retry: "Request failed. Please try again later.",//"请求失败,请稍后重试",
  RSID.request_failed_retry_click: "Request failed. Click to try again.",
  RSID.content_empty: "No data available",//"暂无数据",
  RSID.no_more: "No more",//"没有更多了",
  RSID.net_error: "Network error",//"网络错误",
  RSID.takephoto: "Take a photo",//"拍照",
  RSID.gallery: "Album",//"相册",
  RSID.unknown:"Unknown",//未知
  RSID.request_error:"Request error",//"请求错误",
  RSID.network_exception:"Network exception",//"网络异常",
  RSID.network_exception_retry:"Network exception. Please try again later.",//"网络异常,请稍后重试",
  RSID.connect_timeout:"Connect timeout",//"连接超时",
  RSID.cancel_request:"Cancel request",//"取消请求",


  //----------------------------------------dialog.*
  //BottomDialog
  RSID.dlg_bd_1: "Wallet password",//"钱包密码",
  RSID.dlg_bd_2: "Please enter your wallet password",//"请输入钱包密码",
  RSID.dlg_bd_3: "Please enter your password.",//"请输入密码",
  RSID.dlg_bd_4: "The password is incorrect.",//"密码不正确",
  RSID.dlg_bd_5: "Send transaction",// "发送交易",

  //----------------------------------------views.wallet.*
  //ImportWalletView 导入钱包.  Import wallet
  RSID.iwv_1: "Import EpiK Portal Wallet",//"导入EpiK Portal钱包",
  RSID.iwv_2: "EpiK Portal does not store user passwords and cannot provide a service to retrieve or reset them.",//"请备份好您的密码！EpiK Portal不存储用户密码，无法提供找回或重置的服务。",
  RSID.iwv_3: "Mnemonic word",//"助记词",
  RSID.iwv_4: "Please enter mnemonic words (12 English words) separated by spaces.",//"请输入助记词(12个英文单词)按空格隔开",
  RSID.iwv_5: "Please enter your private key",//"请输入私钥",
  RSID.iwv_6: "Wallet name",//"钱包名称",
  RSID.iwv_7: "Please enter your wallet name",//"请输入钱包名称",
  RSID.iwv_8: "Wallet password",//"钱包密码",
  RSID.iwv_9: "Please enter your wallet password",//"请输入钱包密码",
  RSID.iwv_10: "*Suggest a combinations of upper and lower case letters, symbols, and numbers 8+ digits",//"*建议大小写字母、符号、数字组合 8位以上",
  RSID.iwv_11: "Please confirm your wallet password",//"请确认钱包密码",
  RSID.iwv_12: "Start importing",//"开始导入",
  RSID.iwv_13: "No wallet? to create",//"没有钱包？去创建",
  RSID.iwv_14: "Please enter your password to confirm.",//"请输入确认密码",
  RSID.iwv_15: "The passwords entered must be consistent",//"两次输入的密码必须一致",
  RSID.iwv_16: "The password needs to be at least 8 characters",//"密码至少需要8位",
  RSID.iwv_17: "Please enter the mnemonic",//"请输入助记词",
  RSID.iwv_18: "Incorrect private key format",//"私钥格式不正确",
  RSID.iwv_19: "Import failed, the mnemonic not parsed correctly",//"导入失败，助记词不能正确解析",
  RSID.iwv_20: "Wallet import failed",//"导入失败钱包失败",

  //ExportEpikPrivateKeyView 导出私钥  Export private key
  RSID.eepkv_1: "Export EPK private key",//"导出tEPK私钥",
  RSID.eepkv_2: "Copied private key",//"已复制私钥",
  RSID.eepkv_3: "Copy private key",//"复制私钥",
  RSID.eepkv_4: "Reminder",//导出提示
  RSID.eepkv_5: "What you are exporting is the private key of the test token tEPK. tEPK is a test token of the test network, which is only used in the test network node and has no transaction value. Leaking this private key may lead to the loss of test tokens, but it has nothing to do with the ERC-20 assets in the wallet. You need not worry about the safety of the assets in the ERC-20 wallet. Meanwhile, in the proxy node, the proxy party may need the private key of tEPK for proxy collateral.",
  RSID.eepkv_6: "Export ETH private key",//"导出ETH私钥",
  RSID.eepkv_7: "Remote authorization",//"远程授权",

  //AccountDetailView 钱包账号详情 Wallet details
  RSID.adv_1: "Change password",//"修改密码",
  RSID.adv_2: "Delete wallet",//"删除钱包",
  RSID.adv_3: "Change wallet name",//"修改钱包名称",
  RSID.adv_4: "Deleting wallets...",//"正在删除钱包...",

  //FixPasswordView 修改密码  Change password
  RSID.fpv_1: "Change EpiK Portal wallet password",//"修改EpiK Portal钱包密码",
  RSID.fpv_3: "New wallet password",//"新的钱包密码",
  RSID.fpv_4: "Confirm to change",//"确定修改密码",
  RSID.fpv_5: "Remembered the new password for change?",//"您确定已牢记新的密码并修改钱包密码吗?",

  //CreateWalletView 创建钱包 Create wallet
  RSID.cwtv_1: "Create an EpiK Portal Wallet",//"创建EpiK Portal钱包",
  RSID.cwtv_2: "Already have a wallet? Import now",//"已有钱包？马上导入",

  //CreateMnemonicView 创建助记词 Create mnemonic word
  RSID.cmv_1: "Backup mnemonic word",//"备份助记词",
  RSID.cmv_2: "Back up your mnemonic word, don't screenshot, take pictures, or leak it to anyone!\nThe EpiK Portal does not store user data and cannot provide a retrieve or reset service.",//"请备份好您的助记词，不要截图、拍照，不要泄漏给他人！\nEpiK Portal不存储用户数据，无法提供找回或重置的服务。",
  RSID.cmv_3: "Your mnemonic word",//"您的助记词",
  RSID.cmv_4: "I've backed up.",//"我已备份",

  //VerifyMnemonicView 验证助记词  Verify mnemonic word
  RSID.vmv_1: "Verify mnemonic word",//"验证助记词",
  RSID.vmv_2: "To be on the safe side, fill in the mnemonic word in order to verify that it is valid.",//"为了安全起见，按照顺序填写助记词以确认该助记词是否有效。",
  RSID.vmv_3: "Fill in the mnemonic word",//"填写助记词",
  RSID.vmv_4: "Click on the following phrases in the order of mnemonic word:",//"按助记词顺序点击下面词组：",
  RSID.vmv_5: "Forget mnemonic word, recreate",//"忘记助记词，重新创建",
  RSID.vmv_6: "Please fill in the number fields by clicking on the words in the order of mnemonic word",//"请按助记词顺序点击词组填满数字区域",
  RSID.vmv_7: "Incorrect order of mnemonic word",//"填入的助记词顺序不正确",

  //VerifyCreatePasswordView 验证创建的密码. Verify wallet password
  RSID.vcpv_1: "Verify wallet password",//"验证钱包密码",
  RSID.vcpv_2: "For security, please re-enter your wallet password.",//"为了安全起见，请再次输入钱包密码。",
  RSID.vcpv_3: "Forgot your password? recreate",//"忘记密码？重新创建",
  RSID.vcpv_4: "Incorrect password",//"密码不正确",
  RSID.vcpv_5: "Failed to create wallet",//"创建钱包失败",

  //----------------------------------------views.*
  //MainView 首页框架 Homepage view
  RSID.mainview_1: "Mining",//"挖矿",
  RSID.mainview_2: "Wallet",//"钱包",
  RSID.mainview_3: "Trade",//"交易",
  RSID.mainview_4: "Activitys",//活动，//"Bounty",//"赏金",//
  RSID.mainview_5: "Expert",//专家
  RSID.mainview_6: "Node",//"Minner",//"节点"

  //MiningView 首页_挖矿 Homepage mine
  RSID.main_mv_1: "Pre-mining ranking",//"预挖排行",
  RSID.main_mv_2: "Total bonus",//"预挖总奖励",
  RSID.main_mv_3: "Bonus granted",//"已发放奖励",
  RSID.main_mv_4: "Copied ID",//"已复制ID",
  RSID.main_mv_5: "Bonus acumulated: ",//"累计奖励: ",
  RSID.main_mv_6: "Register",//"报名",
  RSID.main_mv_7: "Under Review\n(Normally take less than 24 hours to approve)",//"审核中",
  RSID.main_mv_8: "Test net profit",//"Pre-mining bonus",//"预挖奖励", 测试网收益
  RSID.main_mv_9: "Register rejected",//"报名已被拒绝",

  //WalletView 首页_钱包 Homapage wallet
  RSID.main_wv_1: "No wallet",//"没有钱包",
  RSID.main_wv_2: "Create wallet",//"创建钱包",
  RSID.main_wv_3: "Already have a wallet",//"已有钱包",
  RSID.main_wv_4: "Import wallet",//"导入钱包",
  RSID.main_wv_5: "Test network 5.0",//"Main network",//"主网",
  RSID.main_wv_6: "Total assets",// "总资产",
  RSID.main_wv_7: "EPK cross chain swap",//"EPK跨链兑换",//ERC20-EPK 兑换 EPK  "ERC20-EPK swap for EPK"
  RSID.main_wv_8: "Get the bounty hunter reward",//"领取赏金猎人奖励",
  RSID.main_wv_9: "ERC20-EPK Uniswap",//ERC20-EPK Uniswap 交易
  RSID.main_wv_10: "Not yet open",//"暂未开通",
  RSID.main_wv_11:"Wallet setting",//钱包设置

  //WalletMenu 首页_钱包侧滑菜单
  RSID.main_mw_1: "Choose wallet",//"钱包",
  RSID.main_mw_2: "Current wallet",//"当前钱包",
  RSID.main_mw_3: "Invalid wallet",//"无效钱包",
  RSID.main_mw_4: "Not now",//"暂不",
  RSID.main_mw_5: "Confirm to delete",//"确定清除",
  RSID.main_mw_6: "Check [%s] is an invalid wallet, delete or not?",//"检测【%s】为无效钱包，是否清除？",

  //TransactionView 首页_交易 Homepage exchange
  RSID.main_tv_1: "Please log in the wallet",//"请先登录钱包",

  //BountyView 首页_赏金 Homepage bounty
  RSID.main_bv_1: "Score",//"积分",
  RSID.main_bv_2: "Swap",//"兑换",
  RSID.main_bv_3: "Introduction",//"说明",
  RSID.main_bv_4: "All",//"全部",
  RSID.main_bv_5: "Claimable",//"可认领",
  RSID.main_bv_6: "Completed",//"已完成",
  RSID.main_bv_7: "You need a wallet to do this",//"需要有钱包才能进行",
  RSID.main_bv_8: "To create wallet",//"去创建钱包",
  RSID.main_bv_9: "You need to sign up for mining before you can proceed",//"需要先参与挖矿报名才能进行",
  RSID.main_bv_10: "To sign up for mining ",//"去报名挖矿",
  RSID.main_bv_11: "Person in charge:",//"负责人:",
  RSID.main_bv_12: "Incentive interval:",//"奖励区间:",
  RSID.main_bv_13: "You need to bind a social account to participate in the activity",
  RSID.main_bv_14: "To bind",

  //----------------------------------------views.mining.*
  //MiningProfitView 预挖收益 Pre-mining profit
  RSID.mpv_1: "Test net profit",//"Pre-mining profit",//"预挖收益",
  RSID.mpv_2: "Mined\nEPK",//"挖出数量\ntEPK",
  RSID.mpv_3: "Granted\nERC20-EPK",//"奖励数量\nERC20-EPK",
  RSID.mpv_4: "Total bonus\nERC20-EPK",//"总奖励\nERC20-EPK",

//MiningSignupView 预挖报名 Register for pre-mining
  RSID.msv_1: "Register for pre-mining",//"预挖报名",
  RSID.msv_2: "Already copied the customer service WeChat account\nPlease add a friend in WeChat account",//"已复制客服微信号\n请在微信添加好友",
  RSID.msv_3: "Before registering, please use the WeChat account you want to bind to add customer service WeChat account ",//"报名前请先使用要绑定的微信号添加客服微信",
  RSID.msv_4: ". After successful registration, the UUID will be displayed and sent to customer service WeChat account.",//"为好友，成功报名后将显示UUID发送给客服微信。",
  RSID.msv_5:
      "EpiK foundation reserves the right to modify, improve or add to the activities or rules at any time during the test, and to cancel the test at any time during and after the test, including but not limited to attempts or suspected exploitation, fraud, malicious intent, or other acts of fraud. Attacks on the network of the participant's entry entitlement and earned mining rewards. Insults, threats to the Organisers, and EpiK foundation reserves the right to disqualify a participant from participating in the Network and from receiving the Mining Bonus.",//"本次测试活动由铭识协议基金会监督，最终解释权归铭识协议基金会所有 ，参与本次活动视为接受以下规定： 铭识协议基金会保留在测试中任何时刻修改、完善和增加测试活动或测试规则的权力，并在测试期间及测试结束后任何时刻均有权取消包括且不限于试图或有嫌疑利用、欺诈、恶意攻击网络的参赛者参赛权益和已获得挖矿奖励。辱骂、威胁主办方，铭识协议基金会保留取消参赛者参赛权益和已获得挖矿奖励的权力。",
  RSID.msv_6: "Blind WeChat account",//"绑定微信号",
  RSID.msv_7: "Please enter WeChat account",//"请输入微信号",
  RSID.msv_8: "Register",//"报名",
  RSID.msv_9_1: "Read already",//"已读上述",
  RSID.msv_9_2: "Event introduction",//"活动说明",
  RSID.msv_10: "Please confirm that you have read the event introduction",//"请确认已读活动说明",
  RSID.msv_11: "Already signed up, please send UUID:%s to Wechat customer service and wait for review. UUID has been copied to the clipboard.",//"已报名，请将UUID:%s发送给微信客服，然后等待审核。UUID已经复制到剪切板。",
  RSID.msv_12: "Failed to register",//"报名失败",
  RSID.msv_13: "WeChat",//"微信",
  RSID.msv_14: "Telegram",
  RSID.msv_15: "Before registering, Please use the Telegram account to join ",//"报名前请先使用要绑定的Telegram账号加入",
  RSID.msv_16: "official Telegram group",
  RSID.msv_17: ". After successful registration, the UUID will be displayed and sent to customer service WeChat account.",//"，成功报名后将显示的UUID发送给官方群中的管理员。",
  RSID.msv_18: "Bind Telegram phone number", //"绑定Telegram使用的手机号",
  RSID.msv_19: "Enter the Telegram phone number",//"请输入注册Telegram使用的手机号",
  RSID.msv_20:  "Already signed up, please send UUID:%s to the administrator in the Telegram group and wait for review. UUID has been copied to the clipboard.",//"已报名，请将UUID:%s发送给Telegram群中的管理员，然后等待审核。UUID已经复制到剪切板。",

  //----------------------------------------views.currency.*
  //CurrencyDetailView 币详情 Token details
  RSID.withdraw: "Transfer",//"转账",
  RSID.deposit: "Receive",//"收款",
  //CurrencyDepositView 收款
  RSID.cdv_1: "Save QR code to album",//"保存二维码到相册",
  RSID.cdv_2: "Wallet address",//"钱包地址",
  RSID.cdv_3: "Copied wallet address",//"已复制钱包地址",
  RSID.cdv_4: " Copy wallet address",//"复制钱包地址",
  RSID.cdv_5: "One moment, please... The QR code is loading.",//"请稍等...二维码正在加载",
  RSID.cdv_6: "QR code saved to album",//"二维码已保存到相册",
  RSID.cdv_7: "Failed to save",//"保存失败",
  RSID.cdv_8:"Please do not transfer the non %s assets to the above address, otherwise the transferred assets will be permanently lost and cannot be recovered.",
  //CurrencyWithdrawView 转账 Transfer
  RSID.cwv_1: "From",//"转出地址", Forwarding address
  RSID.cwv_2: "To",//"接收地址", Receiving address
  RSID.cwv_3: "Enter the address, long press and paste the address or tap to scan the QR code",//"输入地址、长按粘贴地址或点扫描二维码",
  RSID.cwv_4: "Transfer amount",//"转账金额",
  RSID.cwv_5: "All",//"全部",
  RSID.cwv_6: "Enter the amount",//"输入金额",
  RSID.cwv_7: "Fee: %s ETH",//"手续费 : %s eth",
  RSID.cwv_8: "Please enter receiving address",//"请填入接收地址",
  RSID.cwv_9: "Please enter the amount",//"请输入金额",
  RSID.cwv_10: "Transfer amount can't be 0",//"转账金额不能是0",
  RSID.cwv_11: "Failed to transfer",//"转账失败",
  RSID.cwv_12: "Success!",//"操作成功!",
  RSID.cwv_13: "Fee: ",
  RSID.cwv_14:"The balance is not enough",//"余额不足",

  //----------------------------------------views.qrcode.*
  //QrcodeScanView 扫描二维码 Scan QR code
  RSID.qsv_1: "Scan",//"扫一扫",
  RSID.qsv_2: "Invalid QR code",//"无效二维码",
  RSID.qsv_3: "Numbered Mode",//"暂不支持",

  //----------------------------------------views.uniswap.*
  //UniswapView 外壳
  RSID.usv_1: "Transaction records",//"交易记录",
  RSID.usv_2: "Swap",//"兑换",
  RSID.usv_3: "Pool",//"资金池",
  //UniswapPoolView 资金池
  RSID.uspv_1: "Add liquidity",//"注入流动资金",
  RSID.uspv_2: "Pool info",//"资金池信息",
  RSID.uspv_3: "Instructions for use (a must read for newbies)",//"使用说明(新手必读)",
  RSID.uspv_4: "Please log in wallet",//"请先登录钱包",
  RSID.uspv_5: "Pool%s:",//"池中%s:",
  RSID.uspv_6: "Your percentage:",//"您所占份额:",
  RSID.uspv_7: "Last trade time:",//"最后交易时间:",
  RSID.uspv_8: "Add",//"注入",
  RSID.uspv_9: "Withdrawal",//"撤回",
  RSID.uspv_10: "Log in wallet first",//"需要先登录钱包",
  RSID.uspv_11: "Lack the info of pool",//"缺少资金池信息",
  RSID.uspv_12: "No fund to withdrawal",//"您没有可撤回的资金",
  RSID.uspv_13: "EpiK reminds you",//"EpiK提醒您",
  RSID.uspv_14: "Contract",//"合约",
  RSID.uspv_15_1:
      "1.This page is based on Uniswap's ERC20-EPK and USDT's liquidity support \n\n2.The underlying layer is deployed on the ethereum public chain, and both swap and pooling operations will incur ETH fees.\n\n3.The official smart contract address is: ", //"「1」本页资金池交易是基于Uniswap的ERC20-EPK与USDT的流动性支持\n\n「2」底层部署在以太坊公链上，兑换及资金池操作均会产生ETH手续费，操作前请确保钱包有足够的ETH。\n\n「3」官方智能合约地址为：",
  RSID.uspv_15_2: "\n\n4.For instructions for beginners, please click ",//"\n\n「4」新手操作说明请点击",
  RSID.uspv_15_3: "here",//"这里",
  //UniswapExchangeView
  RSID.usev_1: "Estimate",//"预估",
  RSID.usev_2: "Fee : %s ",//"手续费 : %s eth",
  RSID.usev_3: "Slip point : %s%",//"滑点 : %s%",
  RSID.usev_4: "Balance:",//"余额:",
  RSID.usev_5: "All",//"全部",
  RSID.usev_6: "Need to estimate amount",//"需要预估数量",
  RSID.usev_7: "Please enter %s amount",//"请输入%s数量",
  RSID.usev_8: "Amount can't be 0",//"数量不能为0",
  RSID.usev_9: "Estimating the amount...",//"正在预估数量...",
  RSID.usev_10_1:
  "1.This page is based on Uniswap's ERC20-EPK and USDT's liquidity support \n\n2.The underlying layer is deployed on the ethereum public chain, and both swap and pooling operations will incur ETH fees.\n\n3.The official smart contract address is: ",//"「1」本页兑换交易是基于Uniswap的ERC20-EPK与USDT交易\n\n「2」底层部署在以太坊公链上，兑换及资金池操作均会产生ETH手续费，操作前请确保钱包有足够的ETH。\n\n「3」官方智能合约地址为：",
  RSID.usev_10_2: "\n\n4.For instructions for beginners, please click ",//"\n\n「4」新手操作说明请点击",
  RSID.usev_10_3: "here",//"这里",
  RSID.usev_11: "Being submitted to the Ethernet network, please be patient!",//"正在提交到以太坊网络，请耐心等待",
  RSID.usev_12: "Submitted to Ethereum \nThe results will be available later in the transaction history.",//"已提交到以太坊\n稍后可在交易记录中查询结果",
  RSID.usev_13: "Date,Open,High,Low,Close,Change,Change%",//Amount ["时间", "开", "高", "低", "收", "涨跌额", "涨幅",/* "成交量"*/];
  RSID.usev_14: "Slip point : ",//"滑点 : ",
  RSID.usev_15: "Price : ",
  //UniswapPoolAddView 注入资金
  RSID.uspav_1: "The current price is estimated. If the price fluctuates more than %s%, your transaction will be cancelled",//"当前为预估价格，如果价格波动超过%s%，您的交易将会撤销。",
  RSID.uspav_2: "Fee: %s ETH",//"手续费 : %s eth",
  RSID.uspav_3: "Confirm to add",//"确定注入",
  RSID.uspav_4: "Please enter the amount",//"请输入数量",
  RSID.uspav_5: "Submitting",//"正在提交",
  RSID.uspav_6: "Add funds",//"注入资金",
  //UniswapPoolRemoveView 撤回资金
  RSID.usprv_1: "Withdrawal liquidity",//"撤回流动资金",
  RSID.usprv_2: "Withdrawal amount",//"撤回金额",
  RSID.usprv_3: "Confirm to withdrawal",//"确定撤回",
  RSID.usprv_4: "Please choose the amount to withdrawal",//"请选择要撤回的数量",
  //UniswaporderlistView 交易记录
  RSID.usolv_1: "Transaction records",//"交易记录",
  RSID.usolv_1: "Submit time",//"提交时间：",
  RSID.usolv_1: "Details",//"详情",

  //----------------------------------------views.bounty.*
  //BountyDetailView 悬赏任务详情 Bounty task details
  RSID.bdv_1: "Task detail",//"任务详情",
  RSID.bdv_2: "Bonus interval:",//"奖励区间: ",
  RSID.bdv_3: " Bonus allocated info ",//" 奖励分配公示 ",
  RSID.bdv_4: "Task state:",//"任务状态: ",
  RSID.bdv_5: "Edit bonus",//"编辑奖励",
  RSID.bdv_6: "Appeal method:",//"申诉方式: ",
  RSID.bdv_7: "Thanks way:",//"感谢方式: ",
  RSID.bdv_8: "Claim method:",//"认领方式: ",
  RSID.bdv_9: "Wechat account of person in charge",//"联系负责人微信 ",
  RSID.bdv_10: "Copied Wechat account",//"负责人微信已复制",
  RSID.bdv_11: "+ %s scores",//"+ %s 积分",
  RSID.bdv_12:"Remainder:",//"剩余: ",
  RSID.bdv_13: "Edit",//"编辑",
  RSID.bdv_14: "Appeal",//"申诉",
  RSID.bdv_15: "Thanks",//"感谢",
  RSID.bdv_16: "Claim",//"认领",
  //BountyEditView 编辑奖励 Edit bonus
  RSID.bev_1: "Wechat account, the amount of scores (please enter in this format, separated by commas)\n",//"微信号,积分数量 (请按此格式输入,逗号分隔)\n",
  RSID.bev_2: "Total peoples\n",//"总人数\n",
  RSID.bev_3: "Total scores\n",//"总积分\n",
  RSID.bev_4: "Submit the bonus distribution plan for publicity",//"提交奖励分配方案进行公示",
  RSID.bev_5: "Please enter the bonus distribution plan",//"请输入奖励分配方案",
  RSID.bev_6: "Are you sure to submit the current bonus distribution plan and make it public?",//"您确认要提交当前奖励分配方案并进行公示吗？",
  RSID.bev_7: "Submitting",//"正在提交...",
  RSID.bev_8: "The bonus distribution plan has been submitted and publicized",//"奖励分配方案已提交并公示",
  //BountyExchangeRecordListview 兑换记录
  RSID.berlv_1: "Scores",//"积分",
  RSID.berlv_2: "Fee: %s ERC2-EPK",//"手续费: %s ERC2-EPK",
  RSID.berlv_3: "Time:",//"时间:",
  RSID.berlv_4: "Details",//"详情",
  //BountyRewardRecordListview 积分奖励记录 Points reward record
  RSID.brrlv_1: "Complete task",//"完成任务",
  //BountyExchangeView 积分兑换
  RSID.bexv_1: "Scores swap",//"积分兑换",
  RSID.bexv_2: "Current swap ratio: %s scores = 1 ERC20-EPK",//"当前兑换比例：%s 积分 = 1 ERC20-EPK",
  RSID.bexv_3: "Currently WeChat bound: ",//"当前绑定微信：",
  RSID.bexv_4: "Current Ethereum receiving account: ",//"当前以太坊收币账户：",
  RSID.bexv_5: "Please enter swap amount",//"请输入兑换数量",
  RSID.bexv_6: "swap",//"兑换",
  RSID.bexv_7: "Minimum swap quantity: %s scores",//"最少兑换数量：%s 积分",
  RSID.bexv_8: "Estimatedfee: %s ERC20-EPK",//"预估手续费：%s ERC20-EPK",
  RSID.bexv_9: "Bonus records",//"奖励记录",
  RSID.bexv_10: "Swap records",//"兑换记录",
  RSID.bexv_11: "Swap submitting",//"正在提交兑换...",
  RSID.bexv_12: "Scores swap",//"积分兑换",
  RSID.bexv_13: "Scores swap has been submitted,\nplease refresh later to check the wallet balance.",//"积分兑换已提交，\n请稍后刷新查看钱包余额。",
  RSID.bexv_14: "About fee",//"关于手续费",
  RSID.bexv_15:
  "1.An ETH fee is incurred for transfers over Ethernet when redeeming scores for ERC20-EPK.\n\n2.The amount of fees is based on how much ERC20-EPK to deduct based on the ethereum gas fee and the token price in Uniswap.",//"「1」用积分兑换ERC20-EPK时，通过以太网转账会产生ETH手续费；\n\n「2」手续费数量是根据以太坊gas费用和Uniswap中的币价计算出要扣除多少ERC20-EPK。",
  RSID.bexv_16: "Currently Telegram bound：",
  RSID.bexv_17: "Current swap ratio: %s scores = 1 EPK",//"当前兑换比例：%s 积分 = 1 EPK",
  RSID.bexv_18: "Current EPK receiving account:",//"当前EPK收币账户：",
  RSID.bexv_19: "Estimatedfee: %s EPK",//"预估手续费：%s EPK",
  RSID.bexv_20: "When redeeming scores for EPK, you need to deduct the handling charge.",//"用积分兑换EPK时，需要扣除手续费",
  RSID.bexv_21: "Swap amount",//"兑换数量",

  //----------------------------------------logic.*
  //UniswapHistoryMgr.dart
  RSID.uhm_1: "Input funds",//"注入资金",
  RSID.uhm_2: "Withdrawal funds",//"撤回资金",
  RSID.uhm_3: "swap to",//"兑换成",
  //BountyTask.dart
  RSID.bts_1: "(Left: %s)",//"(剩余: %s)",
  RSID.bts_2: "Claimable",//"可认领",
  RSID.bts_3: "Publicity",//"公示中",
  RSID.bts_4: "Completed",//"已完成",
  RSID.bts_5: "All",//"全部",
  RSID.bts_6: "Community",//"社群",
  RSID.bts_7: "Promotion",//"推广",
  RSID.bts_8: "Development",//"开发",
  RSID.bts_9: "Business",//"商务",
  RSID.bts_10: "%s-%s scores",//"%s-%s 积分",
  //BountyUserReward.dart
  RSID.bur_1: "Finish the task",//"完成任务",
  //BountyUserSwap.dart
  RSID.bus_1: "Submitted",//"已提交",
  RSID.bus_2: "Passed",//"已通过",
  RSID.bus_3: "Failed",//"失败",
  RSID.bus_4: "Rejected",//"已拒绝",

  //----------------------------------------MinerView
  RSID.minerview_1:"Pledge",//"抵押",
  RSID.minerview_2:"Withdraw",//"赎回",
  RSID.minerview_3:"Please enter NoteID",//"请输入MinerID",
  RSID.minerview_4:"Add",//"添加",
  RSID.minerview_5:"Storage node",//"存储矿工",
  RSID.minerview_6:"Current power",//"当前算例",
  RSID.minerview_7:"Account balance",//"账户余额",
  RSID.minerview_8:"Lock balance",//"锁定余额",
  RSID.minerview_9:"Extractable balance",//"可提余额",
  RSID.minerview_10:"Node base pledge",//"矿工基础抵押",
  RSID.minerview_11:"My base pledge",//"我的基础抵押",
  RSID.minerview_12:"Retrieve balance",//"流量抵押余额",
  RSID.minerview_13:"Retrieve locked",//"流量抵押锁定",
  RSID.minerview_14:"Retrieve expend",//"当日访问流量",
  RSID.minerview_15:"My retrieve pledge",//"我的流量抵押",
  //---add
  RSID.minerview_15:"Notice:\n- Knowledge nodes need to start the entity miner to participate in storage\n- Knowledge nodes need to complete the basic pledge of 1000 EPK in order to obtain the qualification of block production\n- Knowledge nodes need to read new files from the network and store new files in order to increase computing power and block probability\n- 1EPK = 10Mb daily access traffic, daily used access traffic will be returned\n- You can redeem the pledged EPK at any time",
  RSID.minerview_16:" EPK available",//可用 available
  RSID.minerview_17:"Retrieve pledge",//"访问流量抵押",
  RSID.minerview_18:"Transaction submitted",//"交易已提交",
  RSID.minerview_19:"View details",//"查看交易",
  RSID.minerview_20:"Add pledge submitted",//"添加抵押交易已提交",
  //---withdraw
  RSID.minerview_21:"Notice:\n- Only redeem EPK of its own pledge\n- If you have consumed part of the access traffic at present, you cannot redeem all the access traffic pledge. Please try to reduce the amount of redemption\n- The EPK in the node's basic pledge redemption will arrive immediately\n- EPK accessing traffic pledge can only be redeemed after 3 days of unlocking operation",
  RSID.minerview_22:" EPK can redeem",//赎回
  RSID.minerview_23:" EPK can be unlocked",//可解锁
  RSID.minerview_24:" unlocked",//解锁
  RSID.minerview_25:"Retrieve pledge",//"访问流量抵押",
  RSID.minerview_26:"Redemption submitted",//"赎回抵押交易已提交",
  RSID.minerview_27:"Unlock submitted",//"解锁抵押交易已提交",
  RSID.minerview_28:"My retrieve pledge",//"我的流量抵押",
  RSID.minerview_29:"Remaining height",//"剩余高度",
  RSID.minerview_30:"Coinbase Withdraw",//"Coinbase提取",
  //---MinerMenu
  RSID.minermenu_1:"Choose NoteID",//"选择MinerID",
  RSID.minermenu_2:"Delete NoteID",//"删除MinerID",
  RSID.minermenu_3:"Delete",//删除
  RSID.minermenu_4:"Add NoteID",//"添加MinerID",
  RSID.minermenu_5:"Enter NoteID", //输入MinnerID
  RSID.minermenu_6:"Batch pledge",//"一键抵押",//
  RSID.minermenu_7:"All",//"全选",
  RSID.minermenu_8:"Cancel",//"取消",

  //----------------------------------------ExpertView todo
  RSID.expertview_1:"All",//"全部",
  RSID.expertview_2:"Domain experts",//"领域专家",
  RSID.expertview_3:"Current ARR",//"当前年化收益",  “ARR” Annualized Rate Of Return
  RSID.expertview_4:"Total voted",//"全网总票数",//"已投",
  RSID.expertview_5:"Total profit",//"全网总收益",//"累计收益",
  RSID.expertview_6:"Apply to be domain expert",//"申请成为领域专家",
  RSID.expertview_7:"Domain",//"领域",
  RSID.expertview_8:"profit",//"收益",
  RSID.expertview_9:"Registered",//"已注册",//registered
  RSID.expertview_10:"Nominated",//"已审核",//nominated
  RSID.expertview_11:"Qualified",//"活跃的",//normal qualified
  RSID.expertview_12:"Blocked",//"黑名单",//blocked
  RSID.expertview_13:"Blocked",//"黑名单",//disqualified
  RSID.expertview_14:"Withdrawable",//"可提现收益", //profit
  RSID.expertview_15:"Enter number of withdrawals",//"请输入提取数量",
  RSID.expertview_16:"There is no profit to draw at present",//"当前没有收益可提取",
  RSID.expertview_17:"Your voted",//"您已投出",
  //ApplyExpertView
  RSID.applyexpertview_1:"Apply for domain expert",//"申请领域专家",
  RSID.applyexpertview_2:"Your application has been submitted. Please wait for the result.",//"您的申请已提交，请等待审核结果。",
  RSID.applyexpertview_3:"Apply again",//"再次申请",
  RSID.applyexpertview_4:"Your application has passed",//"您的申请已通过",
  RSID.applyexpertview_5:"Notice",//"申请须知",
  RSID.applyexpertview_6:"Fee",//"费用",
  RSID.applyexpertview_7:"Submit application",//"提交申请",
  RSID.applyexpertview_8:"Please enter your name",//"请输入姓名",
  RSID.applyexpertview_9:"Please enter mobile phone number",//"请输入手机号",
  RSID.applyexpertview_10:"Please enter email",//"请输入邮箱",
  RSID.applyexpertview_11:"Please enter domain",//"请输入领域",
  RSID.applyexpertview_12:"Please enter your profile",//"请输入个人介绍",
  RSID.applyexpertview_13:"Sorry, your application has not passed.",//"很遗憾，您的申请未通过。",
  RSID.applyexpertview_14:"Reason",//"原因",
  RSID.applyexpertview_15:"You can update the application form and submit it for review again",//"您可以更新申请表重新提交审核",
  RSID.applyexpertview_16:"Name (public)",//"姓名(公开)",
  RSID.applyexpertview_17:"Mobile phone number (private)",//"手机号(非公开)",
  RSID.applyexpertview_18:"Email (private)",//"邮箱(非公开)",
  RSID.applyexpertview_19:"Domain (public)",//"想申请的领域(公开)",
  RSID.applyexpertview_20:"Please introduce yourself in terms of educational background, work experience and influence",//"请从教育背景，工作经历，影响力等方面介绍自己",
  RSID.applyexpertview_21:"Personal introduction (public)",//"个人介绍(公开)",
  RSID.applyexpertview_22:"The knowledge map data is subject to open source agreement without any restrictions by default. If there are any special requirements for open source protocol, please fill in the following. (optional)",//"知识图谱数据默认遵循无任何限制的开源协议，如对开源协议有任何特殊要求，请填写如下（选填）",
  RSID.applyexpertview_23:"Open Source License (public)",//"开源协议(公开)",
  RSID.applyexpertview_24:"Waiting for transaction confirmation",//"交易确认中",
  RSID.applyexpertview_25:"Domain expert application has been submitted, please wait for review.",//"领域专家申请已提交，请等待审核。",
  //ExpertInfoView
  RSID.expertinfoview_0:"Details of expert",//"领域专家详情",
  RSID.expertinfoview_1:"Personal profile",//"个人简介",
  RSID.expertinfoview_2:"Open Source License",//"开源协议",
  RSID.expertinfoview_3:"State",//"状态",
  RSID.expertinfoview_4:"Vote",//"投票",
  RSID.expertinfoview_5:"Profit",//"收益",
  RSID.expertinfoview_6:"Voted",//"已投",
  RSID.expertinfoview_7:"Enter amount",//"请输入数额",
  RSID.expertinfoview_8:"Add vote",//"追加投票",
  RSID.expertinfoview_9:"Revoke",//"撤回投票",
  RSID.expertinfoview_10:"Withdraw",//"提取EPK收益",
  RSID.expertinfoview_11:"Please enter the amount",//"请输入数量",
  RSID.expertinfoview_12:"Voted",//"已投票",
  RSID.expertinfoview_13:"Revoked",//"已撤回",
  RSID.expertinfoview_14:"Withdrawed",//"已提取",

  // Erc20ToEpkRecordView  erc20转epk 兑换记录
  RSID.eerv_1:"EPK exchange records",//"EPK兑换记录",
  RSID.eerv_2:"Roll-out transaction",//"转出交易",
  RSID.eerv_3:"Roll-in transaction",//"转入交易",
  RSID.eerv_4:"Failure Reason",//"失败原因",
  RSID.eerv_5:"Retry swap",//"重试提交兑换",
  RSID.eerv_6:"Submitted again",//"已重新提交",

  //Erc20ToEpkView   erc20转epk页面
  RSID.eev_1:"Swap records",//"兑换记录"
  RSID.eev_2:"Start swap",//"发起兑换",
  RSID.eev_3:"Waiting confirmation",//"确认交易",
  RSID.eev_4:"Complete",//"完成",
  RSID.eev_5:"Notes for swap",//"兑换须知",
  RSID.eev_6:"The EPK required for this exchange is provided by the Epik foundation. During the exchange process, you need to initiate an Ethereum transaction, so please make sure that you have enough Ethereum in your current account to pay the transaction fee. After exchange, all ERC20-EPK in your current Ethereum wallet will be destroyed and converted into EPK in the ratio of 1:1. These EPK will be automatically transferred into your current Epik wallet.",//"此次兑换所需的EPK有EpiK基金会提供。兑换过程中，需要您发起一笔以太坊交易，所以请确保您当前账户内有足够的以太坊支付此笔交易的手续费。兑换后，您当前以太坊钱包中的所有ERC20-EPK将会销毁，并按照1:1的比例兑换得到EPK，这些EPK将自动转入您当前EpiK钱包。",
  RSID.eev_7:"Risk statement",//"风险提示",
  RSID.eev_8_1:"In order to prevent you from intentionally or unintentionally disclosing the mnemonic words or private key of the current wallet in previous mining activities, it is strongly recommended to ",//"为避免您之前参与挖矿活动有意或者无意的泄露过当前钱包的助记词或私钥，强烈建议",
  RSID.eev_8_2:"create a new wallet",//"创建新钱包",
  RSID.eev_8_3:", transfer ERC20-EPK into a new wallet, and then swap it.",//"，将ERC20-EPK转入全新的钱包后，再进行兑换。",
  RSID.eev_9:"Disclaimers",//"免责声明",
  RSID.eev_10:"If you destroy ERC20-EPK through other channels, resulting in the failure of normal exchange of EPK, Epik foundation will not compensate.",//"如您通过其他渠道自行销毁了ERC20-EPK导致无法正常兑换EPK，EpiK基金会将不予赔偿",
  RSID.eev_11:"Address:",//"地址:",
  RSID.eev_12:"Amount",//"兑换数量",
  RSID.eev_13:"Swap for ",//"兑换成",
  RSID.eev_14:"Minimum",//"最少兑换",
  RSID.eev_15:"Maximum",//"最多兑换",
  RSID.eev_16:"Fee",//"手续费",
  RSID.eev_17:"Submit txhash to receive EPK",//"已转出交易补领EPK",
  RSID.eev_18:"Submit cid to receive EPK",//"已转出交易补领ERC20-EPK",
  RSID.eev_19:"Transaction failed",//"交易失败",
  RSID.eev_20:"Copied TxHash",//"TxHash已复制",
  RSID.eev_21:"Start new swap",//"发起新的兑换",
  RSID.eev_22:"Waiting for transaction confirmation",//"等待交易确认",
  RSID.eev_23_1:"If not confirmed for a long time, you can ",//"如长时间不上链可以",
  RSID.eev_23_2:"accelerate transaction",//"加速交易",
  RSID.eev_24:"Refresh",//"刷新",
  RSID.eev_25:"Copied cid",//"cid已复制",
  RSID.eev_26:"Swap completed",//"兑换完成",
  RSID.eev_27_1:"Please check in the ", //Please check in the exchange record  //请在兑换记录中查看到账情况
  RSID.eev_27_2:"swap records",
  RSID.eev_27_3:"",
  RSID.eev_28:"Swap quantity limit",//"兑换数量限制",
  RSID.eev_29:"Swap submitted",//"兑换已提交",
  RSID.eev_30:"Enter txhash of the transaction",//"请输入转出ERC20-EPK交易的TxHash",
  RSID.eev_31:"Failed to submit",//"提交失败",
  RSID.eev_32:"Txhash query failed",//"TxHash查询失败",
  RSID.eev_33:"Invalid txhash",//"TxHash无效",
  RSID.eev_34:"Enter cid of the transaction",//"请输入转出EPK交易的cid",
  RSID.eev_35:"Cid query failed",//"cid查询失败",
  RSID.eev_36:"Invalid cid",//"cid无效",
  RSID.eev_37:"Expected to take 6-15 minutes to complete",//"预计 6 - 15 分钟完成",
  RSID.eev_38:"Expected to take 7-8 hours to complete",//"预计 7 - 8 小时完成",

  RSID.er2ep_state_created:"Created",//"已创建",
  RSID.er2ep_state_blocking:"Blocking",//"打包中",
  RSID.er2ep_state_pending:"Bending",//"确认中",
  RSID.er2ep_state_recieved:"Recieved",//"已到账",
  RSID.er2ep_state_paying:"Paying",//"支付中",
  RSID.er2ep_state_success:"Success",//"成功",
  RSID.er2ep_state_failed:"Failed",//"失败",

  // dialog showEthAccelerateTx
  RSID.eatd_1:"Accelerate transaction",//"加速交易",
  RSID.eatd_2:"Enter the gas ratio for acceleration",//"输入加速交易的Gas比例",
  RSID.eatd_3:"Please input acceleration gas ratio",//"请输入加速Gas比例",
  RSID.eatd_4:"The gas ratio needs to be > 1",//"Gas比例需要>1",
  RSID.eatd_5:"Incorrect password",//"密码错误",
  RSID.eatd_6:"Accelerated transaction submitted",//"加速交易已提交",


  //BountyDappListView
  RSID.bdlv_1:"Bounty hunter reward",//"赏金猎人奖励",
  RSID.bdlv_2:"Notice",//"领取须知",
  RSID.bdlv_3_1:"EPK for bounty hunter reward is provided by Epik knowledge fund. In the process of collection, you need to provide ",//"赏金猎人奖励所需的EPK有EpiK知识基金提供。领取过程中，需要您提供",
  RSID.bdlv_3_2:"'s collection token. There is a minimum amount of collection. Only when the balance is greater than the minimum amount can you collect it. After collection, your EPK balance in knowledge continent will be reduced, and your EPK will be automatically transferred into your current Epik wallet.",//"的领取令牌，领取金额有最小限额，只有余额大于最小限额才能领取。领取后您在知识大陆的EPK余额会减少，您领取的EPK将自动转入您当前的EpiK钱包。",
  RSID.bdlv_4:"Risk statement",//"风险提示",
  RSID.bdlv_5_1:"Please make sure that you do not disclose the mnemonics and private key of the current wallet, otherwise it is strongly recommended to ",//"请确保您没有泄露当前钱包助记词和私钥，否则强烈建议",
  RSID.bdlv_5_2:"create a new wallet",//"创建新钱包",
  RSID.bdlv_5_3:" and collect it in the new wallet.",//"，在新钱包中进行领取。",

  //BountyDappTakeRecordView
  RSID.bdtrv_1:"Records",//"领取记录",
  RSID.bdtrv_2:"EPK transaction",//"EPK 发放交易",

  //BountyDappTakeView
  RSID.bdtv_1:"Amount must be greater than ",//"数量需要大于",
  RSID.bdtv_2:"Amount",//"领取数量",
  RSID.bdtv_3:"Fee: ",//"手续费: ",
  RSID.bdtv_4:"Account: ",//"账号: ",
  RSID.bdtv_5:"Name: ",//"名称: ",
  RSID.bdtv_6:"Confirm collection",//"确认领取",
  RSID.bdtv_7:"After confirmation, the application will be submitted and the EPK will be sent to your current wallet after approval.",//"确认领取后会提交领取申请，审核通过后会发放EPK到您当前的钱包",
  RSID.bdtv_8:"Receive EPK",//"领取EPK",
  RSID.bdtv_9:"The collection application has been submitted and will be distributed to your current wallet after being approved. Please check in the collection record.",//"已提交领取申请，审核通过后将发放到您当前钱包，请在领取记录中查看。",
  RSID.bdtv_10:"Receive",//"领取",
  RSID.bdtv_11:"Bind",//"绑定",
  RSID.bdtv_12:"Please enter DAPP's token",//"请输入Dapp的令牌",
  RSID.bdtv_13:"Unbind",//"解绑",
  RSID.bdtv_14:"Are you sure you want to unbind the token of %s account?",//"您确定要解绑%s账号的令牌吗？",
};
