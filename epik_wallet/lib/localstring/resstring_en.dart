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
  RSID.content_empty: "No data available",//"暂无数据",
  RSID.no_more: "No more",//"没有更多了",
  RSID.net_error: "Network error",//"网络错误",
  RSID.takephoto: "Take a photo",//"拍照",
  RSID.gallery: "Album",//"相册",

  //----------------------------------------dialog.*
  //BottomDialog
  RSID.dlg_bd_1: "Wallet password",//"钱包密码",
  RSID.dlg_bd_2: "Please enter your wallet password",//"请输入钱包密码",
  RSID.dlg_bd_3: "Please enter your password.",//"请输入密码",
  RSID.dlg_bd_4: "The password is incorrect.",//"密码不正确",

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
  RSID.eepkv_1: "Export tEPK private key",//"导出tEPK私钥",
  RSID.eepkv_2: "Copied private key",//"已复制私钥",
  RSID.eepkv_3: "Copy private key",//"复制私钥",

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
  RSID.mainview_1: "Mine",//"挖矿",
  RSID.mainview_2: "Wallet",//"钱包",
  RSID.mainview_3: "Trade",//"交易",
  RSID.mainview_4: "Bounty",//"赏金",

  //MiningView 首页_挖矿 Homepage mine
  RSID.main_mv_1: "Pre-mine ranking",//"预挖排行",
  RSID.main_mv_2: "Total bonus",//"预挖总奖励",
  RSID.main_mv_3: "Bonus granted",//"已发放奖励",
  RSID.main_mv_4: "Copied ID",//"已复制ID",
  RSID.main_mv_5: "Bonus acumulated: ",//"累计奖励: ",
  RSID.main_mv_6: "Register",//"报名",
  RSID.main_mv_7: "Under review",//"审核中",
  RSID.main_mv_8: "Pre-mine bonus",//"预挖奖励",
  RSID.main_mv_9: "Register rejected",//"报名已被拒绝",

  //WalletView 首页_钱包 Homapage wallet
  RSID.main_wv_1: "No wallet",//"没有钱包",
  RSID.main_wv_2: "Create wallet",//"创建钱包",
  RSID.main_wv_3: "Already have a wallet",//"已有钱包",
  RSID.main_wv_4: "Import wallet",//"导入钱包",

  //WalletMenu 首页_钱包侧滑菜单
  RSID.main_mw_1: "Wallet",//"钱包",
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

  //----------------------------------------views.mining.*
  //MiningProfitView 预挖收益 Pre-mine profit
  RSID.mpv_1: "Pre-mine profit",//"预挖收益",
  RSID.mpv_2: "mined\ntEPK",//"挖出数量\ntEPK",
  RSID.mpv_3: "granted\nERC20-EPK",//"奖励数量\nERC20-EPK",

//MiningSignupView 预挖报名 Register for pre-mine
  RSID.msv_1: "Register for pre-mine",//"预挖报名",
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
  //CurrencyWithdrawView 转账 Transfer
  RSID.cwv_1: "From",//"转出地址", Forwarding address
  RSID.cwv_2: "To",//"接收地址", Receiving address
  RSID.cwv_3: "Enter the address, long press and paste the address or tap to scan the QR code",//"输入地址、长按粘贴地址或点扫描二维码",
  RSID.cwv_4: "Transfer amount",//"转账金额",
  RSID.cwv_5: "All",//"全部",
  RSID.cwv_6: "Enter the amount",//"输入金额",
  RSID.cwv_7: "Fee : %s eth",//"手续费 : %s eth",
  RSID.cwv_8: "Please enter receiving address",//"请填入接收地址",
  RSID.cwv_9: "Please enter the amount",//"请输入金额",
  RSID.cwv_10: "Transfer amount can't be 0",//"转账金额不能是0",
  RSID.cwv_11: "Failed to transfer",//"转账失败",
  RSID.cwv_12: "Success!",//"操作成功!",

  //----------------------------------------views.qrcode.*
  //QrcodeScanView 扫描二维码 Scan QR code
  RSID.qsv_1: "Scan",//"扫一扫",

  //----------------------------------------views.uniswap.*
  //UniswapView 外壳
  RSID.usv_1: "Transaction record",//"交易记录",
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
  RSID.uspv_15_2: "4.For instructions for beginners, please click ",//"\n\n「4」新手操作说明请点击",
  RSID.uspv_15_3: "here",//"这里",
  //UniswapExchangeView
  RSID.usev_1: "Estimate",//"预估",
  RSID.usev_2: "Fee : %s eth",//"手续费 : %s eth",
  RSID.usev_3: "Slip point : %s%",//"滑点 : %s%",
  RSID.usev_4: "Balance:",//"余额:",
  RSID.usev_5: "All",//"全部",
  RSID.usev_6: "Need to estimate amount",//"需要预估数量",
  RSID.usev_7: "Please enter %s amount",//"请输入%s数量",
  RSID.usev_8: "Amount can't be 0",//"数量不能为0",
  RSID.usev_9: "Estimating the amount...",//"正在预估数量...",
  RSID.usev_10_1:
  "1.This page is based on Uniswap's ERC20-EPK and USDT's liquidity support \n\n2.The underlying layer is deployed on the ethereum public chain, and both swap and pooling operations will incur ETH fees.\n\n3.The official smart contract address is: ",//"「1」本页兑换交易是基于Uniswap的ERC20-EPK与USDT交易\n\n「2」底层部署在以太坊公链上，兑换及资金池操作均会产生ETH手续费，操作前请确保钱包有足够的ETH。\n\n「3」官方智能合约地址为：",
  RSID.usev_10_2: "4.For instructions for beginners, please click ",//"\n\n「4」新手操作说明请点击",
  RSID.usev_10_3: "here",//"这里",
  RSID.usev_11: "Being submitted to the Ethernet network, please be patient!",//"正在提交到以太坊网络，请耐心等待",
  RSID.usev_12: "Submitted to Ethereum \nThe results will be available later in the transaction history.",//"已提交到以太坊\n稍后可在交易记录中查询结果",
  //UniswapPoolAddView 注入资金
  RSID.uspav_1: "The current price is estimated. If the price fluctuates more than %s%, your transaction will be cancelled",//"当前为预估价格，如果价格波动超过%s%，您的交易将会撤销。",
  RSID.uspav_2: "Fee : %s eth",//"手续费 : %s eth",
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
  RSID.usolv_1: "Transaction record",//"交易记录",
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
  RSID.bexv_9: "Bonus record",//"奖励记录",
  RSID.bexv_10: "Swap record",//"兑换记录",
  RSID.bexv_11: "Swap submitting",//"正在提交兑换...",
  RSID.bexv_12: "Scores swap",//"积分兑换",
  RSID.bexv_13: "Scores swap has been submitted,\nplease refresh later to check the wallet balance.",//"积分兑换已提交，\n请稍后刷新查看钱包余额。",
  RSID.bexv_14: "About fee",//"关于手续费",
  RSID.bexv_15:
  "1.An ETH fee is incurred for transfers over Ethernet when redeeming scores for ERC20-EPK.\n\n2.The amount of fees is based on how much ERC20-EPK to deduct based on the ethereum gas fee and the token price in Uniswap.",//"「1」用积分兑换ERC20-EPK时，通过以太网转账会产生ETH手续费；\n\n「2」手续费数量是根据以太坊gas费用和Uniswap中的币价计算出要扣除多少ERC20-EPK。",
  RSID.bexv_16: "Currently Telegram bound：",

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
};
