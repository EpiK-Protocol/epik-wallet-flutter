import 'package:epikwallet/localstring/resstringid.dart';

// 中文字符表
Map<RSID, String> map_zh = {
  //base
  RSID.doubleclickquit: "再按一次退出",
  RSID.copy:"复制",
  RSID.copied: "已复制到剪切板",
  RSID.tip: "提示",
  RSID.confirm: "确定",
  RSID.cancel: "取消",
  RSID.last_step: "上一步",
  RSID.next_step: "下一步",
  RSID.isee: "知道了",
  RSID.upgrade_tip: "版本升级提示",
  RSID.upgrade_des: "有新版本%s,",
  RSID.upgrade_des_1: "需要升级\n如不升级可能会影响正常功能",
  RSID.upgrade_des_2: "可以升级\n是否现在升级?",
  RSID.upgrade_confirm: "升级",
  RSID.upgrade_cancel: "取消",
  RSID.completed: "已完成",
  RSID.request_failed: "请求失败",
  RSID.request_failed_retry: "请求失败,请稍后重试",
  RSID.request_failed_retry_click: "加载失败, 点击重试",
  RSID.request_failed_checknetwork:"数据加载失败\n请检查网络",
  RSID.content_empty: "暂无数据",
  RSID.no_more: "没有更多了",
  RSID.net_error: "网络错误",
  RSID.takephoto: "拍照",
  RSID.gallery: "相册",
  RSID.unknown:"未知",
  RSID.request_error:"请求错误",
  RSID.network_exception:"网络异常",
  RSID.network_exception_retry:"网络异常,请稍后重试",//  "Request failed. Please try again later.",
  RSID.connect_timeout:"连接超时",
  RSID.cancel_request:"取消请求",// Cancel request
  RSID.retry:"重试",

  //----------------------------------------dialog.*
  //BottomDialog
  RSID.dlg_bd_1: "钱包密码",
  RSID.dlg_bd_2: "请输入钱包密码",
  RSID.dlg_bd_3: "请输入密码",
  RSID.dlg_bd_4: "密码不正确",
  RSID.dlg_bd_5: "发送交易",

  //----------------------------------------views.wallet.*
  //ImportWalletView 导入钱包
  RSID.iwv_1: "导入EpiK Portal钱包",
  RSID.iwv_2: "请备份好您的密码！EpiK Portal 不存储用户密码，无法提供找回或重置的服务。",
  RSID.iwv_3: "助记词",
  RSID.iwv_4: "请输入助记词(12个英文单词)按空格隔开",
  RSID.iwv_5: "请输入私钥",
  RSID.iwv_6: "钱包名称",
  RSID.iwv_7: "请输入钱包名称",
  RSID.iwv_8: "钱包密码",
  RSID.iwv_9: "请输入钱包密码",
  RSID.iwv_10: "*建议大小写字母、符号、数字组合 8位以上",
  RSID.iwv_11: "请确认钱包密码",
  RSID.iwv_12: "开始导入",
  RSID.iwv_13: "没有钱包？去创建",
  RSID.iwv_14: "请输入确认密码",
  RSID.iwv_15: "两次输入的密码必须一致",
  RSID.iwv_16: "密码至少需要8位",
  RSID.iwv_17: "请输入助记词",
  RSID.iwv_18: "私钥格式不正确",
  RSID.iwv_19: "导入失败，助记词不能正确解析",
  RSID.iwv_20: "导入钱包失败",
  RSID.iwv_21:"私钥",
  RSID.iwv_22:"请输入EpiK私钥(十六进制)",
  RSID.iwv_23:"请输入Ethereum私钥(十六进制)",
  RSID.iwv_24:"EpiK私钥",
  RSID.iwv_25:"Ethereum私钥",
  RSID.iwv_26:"至少需要输入一种私钥",
  RSID.iwv_27:"EpiK私钥错误",
  RSID.iwv_28:"Ethereum私钥错误",
  RSID.iwv_29:"需要EpiK钱包",


  //ExportEpikPrivateKeyView 导出私钥
  RSID.eepkv_1: "导出EPK私钥",
  RSID.eepkv_2: "已复制私钥",
  RSID.eepkv_3: "复制私钥",
  RSID.eepkv_4: "温馨提示",//导出提示
  RSID.eepkv_5: "您正在导出的是EPK的私钥，EPK是您的重要资产。获得私钥等于拥有钱包所有权，泄露此私钥将有可能失去全部资产。请务必保管好，切勿泄露给他人。",
  RSID.eepkv_6: "导出ETH私钥",
  RSID.eepkv_7: "远程授权",

  //AccountDetailView 钱包账号详情
  RSID.adv_1: "修改密码",
  RSID.adv_2: "删除钱包",
  RSID.adv_3: "修改钱包名称",
  RSID.adv_4: "正在删除钱包...",

  //FixPasswordView 修改密码
  RSID.fpv_1: "修改EpiK Portal钱包密码",
  RSID.fpv_3: "新的钱包密码",
  RSID.fpv_4: "确定修改密码",
  RSID.fpv_5: "您确定已牢记新的密码并修改钱包密码吗?",

  //CreateWalletView 创建钱包
  RSID.cwtv_1: "创建EpiK Portal钱包",
  RSID.cwtv_2: "已有钱包？马上导入",

  //CreateMnemonicView 创建助记词
  RSID.cmv_1: "备份助记词",
  RSID.cmv_2: "请备份好您的助记词，不要截图、拍照，不要泄漏给他人！\nEpiK Portal不存储用户数据，无法提供找回或重置的服务。",
  RSID.cmv_3: "您的助记词",
  RSID.cmv_4: "我已备份",

  //VerifyMnemonicView 验证助记词
  RSID.vmv_1: "验证助记词",
  RSID.vmv_2: "为了安全起见，按照顺序填写助记词以确认该助记词是否有效。",
  RSID.vmv_3: "填写助记词",
  RSID.vmv_4: "按助记词顺序点击下面词组：",
  RSID.vmv_5: "忘记助记词，重新创建",
  RSID.vmv_6: "请按助记词顺序点击词组填满数字区域",
  RSID.vmv_7: "填入的助记词顺序不正确",

  //VerifyCreatePasswordView 验证创建的密码
  RSID.vcpv_1: "验证钱包密码",
  RSID.vcpv_2: "为了安全起见，请再次输入钱包密码。",
  RSID.vcpv_3: "忘记密码？重新创建",
  RSID.vcpv_4: "密码不正确",
  RSID.vcpv_5: "创建钱包失败",

  //----------------------------------------views.*
  //MainView 首页框架
  RSID.mainview_1: "挖矿",
  RSID.mainview_2: "钱包",
  RSID.mainview_3: "交易",
  RSID.mainview_4: "活动",//"赏金",
  RSID.mainview_5: "专家",
  RSID.mainview_6: "节点",//"矿工",

  //MiningView 首页_挖矿
  RSID.main_mv_1: "预挖排行",
  RSID.main_mv_2: "预挖总奖励",
  RSID.main_mv_3: "已发放奖励",
  RSID.main_mv_4: "已复制ID",
  RSID.main_mv_5: "累计奖励: ",
  RSID.main_mv_6: "报名",
  RSID.main_mv_7: "审核中\n(一般在24小时内完成)",
  RSID.main_mv_8: "测试网收益",//"预挖奖励",
  RSID.main_mv_9: "报名已被拒绝",

  //WalletView 首页_钱包
  RSID.main_wv_1: "没有钱包",
  RSID.main_wv_2: "创建钱包",
  RSID.main_wv_3: "已有钱包",
  RSID.main_wv_4: "导入钱包",
  RSID.main_wv_5: "测试网5.0",//主网
  RSID.main_wv_6: "总资产",
  RSID.main_wv_7: "EPK跨链兑换",//"ERC20-EPK 兑换 EPK",
  RSID.main_wv_8: "领取赏金猎人奖励",
  RSID.main_wv_9: "ERC20-EPK Uniswap 交易",
  RSID.main_wv_10: "暂未开放",
  RSID.main_wv_11:"钱包设置",

  //WalletMenu 首页_钱包侧滑菜单
  RSID.main_mw_1: "选择钱包",
  RSID.main_mw_2: "当前钱包",
  RSID.main_mw_3: "无效钱包",
  RSID.main_mw_4: "暂不",
  RSID.main_mw_5: "确定清除",
  RSID.main_mw_6: "检测【%s】为无效钱包，是否清除？",

  //TransactionView 首页_交易
  RSID.main_tv_1: "请先登录钱包",

  //BountyView 首页_赏金
  RSID.main_bv_1: "积分",
  RSID.main_bv_2: "兑换",
  RSID.main_bv_3: "说明",
  RSID.main_bv_4: "全部",
  RSID.main_bv_5: "可认领",
  RSID.main_bv_6: "已完成",
  RSID.main_bv_7: "需要有钱包才能进行",
  RSID.main_bv_8: "去创建钱包",
  RSID.main_bv_9: "需要先参与挖矿报名才能进行",
  RSID.main_bv_10: "去报名挖矿",
  RSID.main_bv_11: "负责人:",
  RSID.main_bv_12: "奖励区间:",
  RSID.main_bv_13: "参加活动需要绑定社交账号",
  RSID.main_bv_14: "去绑定",
  RSID.main_bv_15: "需要完整的钱包",//Full wallet required

  //----------------------------------------views.mining.*
  //MiningProfitView 预挖收益
  RSID.mpv_1: "测试网收益",//"预挖收益",
  RSID.mpv_2: "挖出数量\nEPK",
  RSID.mpv_3: "奖励数量\nERC20-EPK",
  RSID.mpv_4: "总奖励\nERC20-EPK",

  //MiningSignupView 预挖报名
  RSID.msv_1: "预挖报名",
  RSID.msv_2: "已复制客服微信号\n请在微信添加好友",
  RSID.msv_3: "报名前请先使用要绑定的微信号添加客服微信",
  RSID.msv_4: "，成功报名后将显示的UUID发送给客服微信。",
  RSID.msv_5: "本次测试活动由铭识协议基金会监督，最终解释权归铭识协议基金会所有 ，参与本次活动视为接受以下规定： 铭识协议基金会保留在测试中任何时刻修改、完善和增加测试活动或测试规则的权力，并在测试期间及测试结束后任何时刻均有权取消包括且不限于试图或有嫌疑利用、欺诈、恶意攻击网络的参赛者参赛权益和已获得挖矿奖励。辱骂、威胁主办方，铭识协议基金会保留取消参赛者参赛权益和已获得挖矿奖励的权力。",
  RSID.msv_6: "绑定微信号",
  RSID.msv_7: "请输入微信号",
  RSID.msv_8: "报名",
  RSID.msv_9_1: "已读上述",
  RSID.msv_9_2: "活动说明",
  RSID.msv_10: "请确认已读活动说明",
  RSID.msv_11: "已报名，请将UUID:%s发送给微信客服，然后等待审核。UUID已经复制到剪切板。",
  RSID.msv_12: "报名失败",
  RSID.msv_13: "微信",
  RSID.msv_14: "Telegram",
  RSID.msv_15: "报名前请先使用要绑定的Telegram账号加入",
  RSID.msv_16: "Telegram官方群",
  RSID.msv_17: "，成功报名后将显示的UUID发送给官方群中的管理员。",
  RSID.msv_18: "绑定Telegram使用的手机号",
  RSID.msv_19: "请输入注册Telegram使用的手机号",
  RSID.msv_20: "已报名，请将UUID:%s发送给Telegram群中的管理员，然后等待审核。UUID已经复制到剪切板。",

  //----------------------------------------views.currency.*
  //CurrencyDetailView 币详情
  RSID.withdraw: "转账",
  RSID.deposit: "收款",
  //CurrencyDepositView 收款
  RSID.cdv_1: "保存二维码到相册",
  RSID.cdv_2: "钱包地址",
  RSID.cdv_3: "已复制钱包地址",
  RSID.cdv_4: "复制钱包地址",
  RSID.cdv_5: "请稍等...二维码正在加载",
  RSID.cdv_6: "二维码已保存到相册",
  RSID.cdv_7: "保存失败",
  RSID.cdv_8:"请勿转入非 %s 资产到以上地址，否则转入资产将永久损失且无法找回。",
  //CurrencyWithdrawView 转账
  RSID.cwv_1: "转出地址",
  RSID.cwv_2: "接收地址",
  RSID.cwv_3: "输入地址、长按粘贴地址或点扫描二维码",
  RSID.cwv_4: "转账金额",
  RSID.cwv_5: "全部",
  RSID.cwv_6: "输入金额",
  RSID.cwv_7: "手续费: %s ",
  RSID.cwv_8: "请填入接收地址",
  RSID.cwv_9: "请输入金额",
  RSID.cwv_10: "转账金额不能是0",
  RSID.cwv_11: "转账失败",
  RSID.cwv_12: "操作成功!",
  RSID.cwv_13: "手续费: ",
  RSID.cwv_14:"余额不足",

  //----------------------------------------views.qrcode.*
  //QrcodeScanView 扫描二维码
  RSID.qsv_1: "扫一扫",
  RSID.qsv_2: "无效二维码",
  RSID.qsv_3: "暂不支持",

  //----------------------------------------views.uniswap.*
  //UniswapView 外壳
  RSID.usv_1: "交易记录",
  RSID.usv_2: "兑换",
  RSID.usv_3: "资金池",
  //UniswapPoolView 资金池
  RSID.uspv_1: "注入流动资金",
  RSID.uspv_2: "资金池信息",
  RSID.uspv_3: "使用说明(新手必读)",
  RSID.uspv_4: "请先登录钱包",
  RSID.uspv_5: "池中%s:",
  RSID.uspv_6: "您所占份额:",
  RSID.uspv_7: "最后交易时间:",
  RSID.uspv_8: "注入",
  RSID.uspv_9: "撤回",
  RSID.uspv_10: "需要先登录钱包",
  RSID.uspv_11: "缺少资金池信息",
  RSID.uspv_12: "您没有可撤回的资金",
  RSID.uspv_13: "EpiK提醒您",
  RSID.uspv_14: "合约",
  RSID.uspv_15_1: "「1」本页资金池交易是基于Uniswap的ERC20-EPK与USDT的流动性支持\n\n「2」底层部署在以太坊公链上，兑换及资金池操作均会产生ETH手续费，操作前请确保钱包有足够的ETH。\n\n「3」官方智能合约地址为：",
  RSID.uspv_15_2: "\n\n「4」新手操作说明请点击",
  RSID.uspv_15_3: "这里",
  //UniswapExchangeView
  RSID.usev_1: "预估",
  RSID.usev_2: "手续费 : %s ",
  RSID.usev_3: "滑点 : %s%",
  RSID.usev_4: "余额:",
  RSID.usev_5: "全部",
  RSID.usev_6: "需要预估数量",
  RSID.usev_7: "请输入%s数量",
  RSID.usev_8: "数量不能为0",
  RSID.usev_9: "正在预估数量...",
  RSID.usev_10_1: "「1」本页兑换交易是基于Uniswap的ERC20-EPK与USDT交易\n\n「2」底层部署在以太坊公链上，兑换及资金池操作均会产生ETH手续费，操作前请确保钱包有足够的ETH。\n\n「3」官方智能合约地址为：",
  RSID.usev_10_2: "\n\n「4」新手操作说明请点击",
  RSID.usev_10_3: "这里",
  RSID.usev_11: "正在提交到以太坊网络，请耐心等待",
  RSID.usev_12: "已提交到以太坊\n稍后可在交易记录中查询结果",
  RSID.usev_13: "时间,开,高,低,收,涨跌额,涨幅",//["时间", "开", "高"usev_2
  RSID.usev_14: "滑点 : ",
  RSID.usev_15: "价格 : ",
  // , "低", "收", "涨跌额", "涨幅",/* "成交量"*/];
  //UniswapPoolAddView 注入资金
  RSID.uspav_1: "当前为预估价格，如果价格波动超过%s%，您的交易将会撤销。",
  RSID.uspav_2: "手续费: %s ETH",
  RSID.uspav_3: "确定注入",
  RSID.uspav_4: "请输入数量",
  RSID.uspav_5: "正在提交",
  RSID.uspav_6: "注入资金",
  //UniswapPoolRemoveView 撤回资金
  RSID.usprv_1: "撤回流动资金",
  RSID.usprv_2: "撤回金额",
  RSID.usprv_3: "确定撤回",
  RSID.usprv_4: "请选择要撤回的数量",
  //UniswaporderlistView 交易记录
  RSID.usolv_1: "交易记录",
  RSID.usolv_2: "提交时间：",
  RSID.usolv_3: "详情",

  //----------------------------------------views.bounty.*
  //BountyDetailView 悬赏任务详情
  RSID.bdv_1: "任务详情",
  RSID.bdv_2: "奖励区间: ",
  RSID.bdv_3: " 奖励分配公示 ",
  RSID.bdv_4: "任务状态: ",
  RSID.bdv_5: "编辑奖励",
  RSID.bdv_6: "申诉方式: ",
  RSID.bdv_7: "感谢方式: ",
  RSID.bdv_8: "认领方式: ",
  RSID.bdv_9: "联系负责人微信",
  RSID.bdv_10: "负责人微信已复制",
  RSID.bdv_11: "+ %s 积分",
  RSID.bdv_12:"剩余: ",
  RSID.bdv_13: "编辑",
  RSID.bdv_14: "申诉",
  RSID.bdv_15: "感谢",
  RSID.bdv_16: "认领",
  //BountyEditView 编辑奖励
  RSID.bev_1: "微信号,积分数量 (请按此格式输入,逗号分隔)\n",
  RSID.bev_2: "总人数\n",
  RSID.bev_3: "总积分\n",
  RSID.bev_4: "提交奖励分配方案进行公示",
  RSID.bev_5: "请输入奖励分配方案",
  RSID.bev_6: "您确认要提交当前奖励分配方案并进行公示吗？",
  RSID.bev_7: "正在提交...",
  RSID.bev_8: "奖励分配方案已提交并公示",
  //BountyExchangeRecordListview 兑换记录
  RSID.berlv_1: " 积分",
  RSID.berlv_2: "手续费: %s ERC2-EPK",
  RSID.berlv_3: "时间:",
  RSID.berlv_4: "详情",
  //BountyRewardRecordListview 积分奖励记录
  RSID.brrlv_1: "完成任务",
  //BountyExchangeView 积分兑换
  RSID.bexv_1: "积分兑换",
  RSID.bexv_2: "当前兑换比例：%s 积分 = 1 ERC20-EPK",
  RSID.bexv_3: "当前绑定微信：",
  RSID.bexv_4: "当前以太坊收币账户：",
  RSID.bexv_5: "请输入兑换数量",
  RSID.bexv_6: "兑换",
  RSID.bexv_7: "最少兑换数量：%s 积分",
  RSID.bexv_8: "预估手续费：%s ERC20-EPK",
  RSID.bexv_9: "奖励记录",
  RSID.bexv_10: "兑换记录",
  RSID.bexv_11: "正在提交兑换...",
  RSID.bexv_12: "积分兑换",
  RSID.bexv_13: "积分兑换已提交，\n请稍后刷新查看钱包余额。",
  RSID.bexv_14: "关于手续费",
  RSID.bexv_15: "「1」用积分兑换ERC20-EPK时，通过以太网转账会产生ETH手续费；\n\n「2」手续费数量是根据以太坊gas费用和Uniswap中的币价计算出要扣除多少ERC20-EPK。",
  RSID.bexv_16: "当前绑定Telegram：",
  RSID.bexv_17: "当前兑换比例：%s 积分 = 1 EPK",
  RSID.bexv_18: "当前EPK收币账户：",
  RSID.bexv_19: "预估手续费：%s EPK",
  RSID.bexv_20: "用积分兑换EPK时，需要扣除手续费",
  RSID.bexv_21: "兑换数量",

  //----------------------------------------logic.*
  //UniswapHistoryMgr.dart
  RSID.uhm_1: "注入资金",
  RSID.uhm_2: "撤回资金",
  RSID.uhm_3: "兑换成",
  //BountyTask.dart
  RSID.bts_1: "(剩余: %s)",
  RSID.bts_2: "可认领",
  RSID.bts_3: "公示中",
  RSID.bts_4: "已完成",
  RSID.bts_5: "全部",
  RSID.bts_6: "社群",
  RSID.bts_7: "推广",
  RSID.bts_8: "开发",
  RSID.bts_9: "商务",
  RSID.bts_10: "%s-%s 积分",
  //BountyUserReward.dart
  RSID.bur_1: "完成任务",
  //BountyUserSwap.dart
  RSID.bus_1: "已提交",
  RSID.bus_2: "已通过",
  RSID.bus_3: "失败",
  RSID.bus_4: "已拒绝",

  //----------------------------------------MinerView
  RSID.minerview_1:"抵押",
  RSID.minerview_2:"赎回",
  RSID.minerview_3:"请输入 NodeID",//"请输入MinerID",NodeID
  RSID.minerview_4:"添加",
  RSID.minerview_5:"知识节点",//"存储节点",//"存储矿工",
  RSID.minerview_6:"当前算力",
  RSID.minerview_7:"账户余额",
  RSID.minerview_8:"锁定余额",
  RSID.minerview_9:"可提余额",
  RSID.minerview_10:"节点基础抵押",//"矿工基础抵押",
  RSID.minerview_11:"我的基础抵押",
  RSID.minerview_12:"流量抵押余额",
  RSID.minerview_13:"流量抵押锁定",
  RSID.minerview_14:"当日访问流量",
  RSID.minerview2_1:"总余额",
  RSID.minerview2_2:"锁定中",
  RSID.minerview2_3:"已解锁",
  RSID.minerview2_4:"提现",
  RSID.minerview2_5:"总算力",
  RSID.minerview2_6:"总质押",
  RSID.minerview2_7:"节点质押",
  RSID.minerview2_8:"流量质押",
  RSID.minerview2_9:"节点数据",
  RSID.minerview2_10:"查看全部节点",
  RSID.minerview2_11:"节点总数",
  RSID.minerview2_12:"激活节点",
  RSID.minerview2_13:"算力不足",
  RSID.minerview2_14:"错误节点",
  RSID.minerview2_15:"已质押",
  RSID.minerview2_16:"我质押的",
  RSID.minerview2_17:"流量",
  RSID.minerview2_18:"查看 Owner",
  RSID.minerview2_19:"总流量质押",
  RSID.minerview2_20:"质押中",
  //---add
  RSID.minerview_15:"注意：\n- 您需要启动物理机器才能成为知识节点\n- 一个知识节点需要完成 1000EPK 的节点基础抵押才能获得出块资格\n- 知识节点需要从网络里读取新文件，存储新文件才能增加算力，增大出块概率 \n- 1EPK = 10Mib 的每日访问流量，每日已用访问流量将会刷新\n- 您可以在任何时候赎回抵押的 EPK",//"注意：\n- 知识矿工需要启动实体矿机才能参与挖矿\n- 知识矿工需要完成1000EPK的矿工基础抵押才能获得出块资格\n- 知识矿工需要从网络里读取新文件，存储新文件才能增加算力，增大出块概率 \n- 1EPK=10Mb的每日访问流量，每日已用访问流量将会返还\n- 您可以在任何时候赎回抵押的EPK",
  RSID.minerview_16:" EPK 可用",
  RSID.minerview_17:"访问流量抵押",
  RSID.minerview_18:"交易已提交",
  RSID.minerview_19:"查看交易",
  RSID.minerview_20:"添加抵押交易已提交",
  //---withdraw
  RSID.minerview_21:"注意：\n- 仅能赎回自己抵押的EPK\n- 如果你当前已经消耗了一部分访问流量，则无法赎回全部的访问流量抵押，请尝试减少赎回的数量\n- 节点基础抵押赎回中的EPK将会立刻到账\n- 访问流量抵押的EPK需要在解锁操作3天后才能赎回",//"注意：\n- 仅能赎回自己抵押的EPK\n- 如果你当前已经消耗了一部分访问流量，则无法赎回全部的访问流量抵押，请尝试减少赎回的数量\n- 矿工基础抵押赎回中的EPK将会立刻到账\n- 访问流量抵押的EPK需要在解锁操作3天后才能赎回",
  RSID.minerview_22:" EPK 可赎回",
  RSID.minerview_23:" EPK 可解锁",
  RSID.minerview_24:" 解锁",
  RSID.minerview_25:"访问流量抵押",
  RSID.minerview_26:"赎回抵押交易已提交",
  RSID.minerview_27:"解锁抵押交易已提交",
  RSID.minerview_28:"我的流量抵押",
  RSID.minerview_29:"剩余高度",
  RSID.minerview_30:"Coinbase提取",
  //---MinerMenu
  RSID.minermenu_1:"选择NodeID",//"选择MinerID",
  RSID.minermenu_2:"删除NodeID",//"删除MinerID",
  RSID.minermenu_3:"删除",
  RSID.minermenu_4:"添加NodeID",//"添加MinerID",
  RSID.minermenu_5:"请输入NodeID",//"请输入MinerID",
  RSID.minermenu_6:"批量抵押",//
  RSID.minermenu_7:"全选",
  RSID.minermenu_8:"取消",

  //----------------------------------------ExpertView
  RSID.expertview_1:"全部",
  RSID.expertview_2:"领域专家",
  RSID.expertview_3:"当前年化收益",
  RSID.expertview_4:"全网总票数",//"已投",
  RSID.expertview_5:"全网总收益",//"累计收益",
  RSID.expertview_6:"申请成为领域专家",
  RSID.expertview_7:"领域",
  RSID.expertview_8:"收益",
  RSID.expertview_9:"已注册",//registered
  RSID.expertview_10:"已审核",//nominated
  RSID.expertview_11:"活跃的",//normal
  RSID.expertview_12:"黑名单",//blocked
  RSID.expertview_13:"黑名单",//disqualified
  RSID.expertview_14:"可提现收益",
  RSID.expertview_15:"请输入提取数量",
  RSID.expertview_16:"当前没有可提取的EPK",
  RSID.expertview_17:"您已投出",
  RSID.expertview_18:"解锁中",
  RSID.expertview_19:"已解锁",
  RSID.expertview_20:" (已提交)",
  RSID.expertview_21:" (已通过)",
  RSID.expertview_22:" (被拒绝)",
  RSID.expertview_23:"求助",//  Seek Help
  RSID.expertview_24:"您的申请ID:%s\n您可以把ID发送给其他领域专家帮助您通过审核",//
  RSID.expertview_25:"助力",
  RSID.expertview_26:"输入他人领域专家的申请ID，可以帮助他人通过审核。",
  RSID.expertview_27:"提名",
  RSID.expertview_28:"已提名",


  //ApplyExpertView
  RSID.applyexpertview_1:"申请领域专家",
  RSID.applyexpertview_2:"您的申请已提交，请等待审核结果。",
  RSID.applyexpertview_3:"再次申请",
  RSID.applyexpertview_4:"您的申请已通过",
  RSID.applyexpertview_5:"申请须知",
  RSID.applyexpertview_6:"费用",
  RSID.applyexpertview_7:"提交申请",
  RSID.applyexpertview_8:"请输入姓名",
  RSID.applyexpertview_9:"请输入手机号",
  RSID.applyexpertview_10:"请输入邮箱",
  RSID.applyexpertview_11:"请输入领域",
  RSID.applyexpertview_12:"请输入个人介绍",
  RSID.applyexpertview_13:"很遗憾，您的申请未通过。",
  RSID.applyexpertview_14:"原因",
  RSID.applyexpertview_15:"您可以更新申请表重新提交审核",
  RSID.applyexpertview_16:"姓名",
  RSID.applyexpertview_17:"手机号(非公开)",
  RSID.applyexpertview_18:"邮箱(非公开)",
  RSID.applyexpertview_19:"领域",
  RSID.applyexpertview_20:"请从教育背景，工作经历，影响力等方面介绍自己",
  RSID.applyexpertview_21:"个人介绍(公开)",
  RSID.applyexpertview_22:"知识图谱数据默认遵循无任何限制的开源协议，如对开源协议有任何特殊要求，请填写如下（选填）",
  RSID.applyexpertview_23:"开源协议(公开)",
  RSID.applyexpertview_24:"交易确认中",
  RSID.applyexpertview_25:"领域专家申请已提交，请等待审核。",
  RSID.applyexpertview_26:"语言",//
  RSID.applyexpertview_27:"推特",//
  RSID.applyexpertview_28:"领英",//
  RSID.applyexpertview_29:"为什么你是这个领域的合适人选？",// Why are you the right person of this domain?
  RSID.applyexpertview_30:"您将如何根据该领域收集的数据开发或推广应用程序？",//你会如何推动AI应用来使用这个领域的数据并从中获益？How will you develop or promote the applications to be nefit from the data collected in this domain?
  RSID.applyexpertview_31:"基础信息",// Basic Infomation
  RSID.applyexpertview_32:"告诉大家你是谁",// Please tell all EPKers who you are.
  RSID.applyexpertview_33:"专业介绍",// Professional Introduction
  RSID.applyexpertview_34:"请选择一个领域，并结合您自己的经验告诉大家您是该领域专家最适合的人选。",// Please choose one domain and combine your own experience to tell all EPKers that you are the right person to be the domain expert in this domain.
  RSID.applyexpertview_35:"人工智能应用程序",// AI Application
  RSID.applyexpertview_36:"请告诉大家，该领域中的数据将非常有用，您可以开发一个新的AI应用程序或找到一个现有的AI应用程序，以使该领域中的数据受益。",// Please tell all EPKers that the data in this domain will be very useful and you could develop a new AI application or find an existing AI application to benefit the data in this domain.
  RSID.applyexpertview_37:"请选择语言",
  RSID.applyexpertview_38:"请输入推特",
  RSID.applyexpertview_39:"请输入领英",
  RSID.applyexpertview_40:"请输入为什么您是合适人选",
  RSID.applyexpertview_41:"请输入您怎么开发或使用现有人工智能应用",
  RSID.applyexpertview_42:"为什么我能做好这个领域？",
  RSID.applyexpertview_43:"我会如何推动AI应用来使这个领域中的数据收益",
  //ExpertInfoView
  RSID.expertinfoview_0:"领域专家详情",
  RSID.expertinfoview_1:"个人简介",
  RSID.expertinfoview_2:"开源协议",
  RSID.expertinfoview_3:"状态",
  RSID.expertinfoview_4:"投票",
  RSID.expertinfoview_5:"收益",
  RSID.expertinfoview_6:"已投",
  RSID.expertinfoview_7:"请输入数额",
  RSID.expertinfoview_8:"追加投票",
  RSID.expertinfoview_9:"撤回投票",
  RSID.expertinfoview_10:"提取EPK",
  RSID.expertinfoview_11:"请输入数量",
  RSID.expertinfoview_12:"已投票",
  RSID.expertinfoview_13:"已撤回",
  RSID.expertinfoview_14:"已提取",
  RSID.expertinfoview_15:"查看",
  RSID.expertinfoview_16:"自己", //自己
  RSID.expertinfoview_17:"您已成为领域专家，可以去领域专家后台发布任务。",

  // Erc20ToEpkRecordView  erc20转epk 兑换记录
  RSID.eerv_1:"兑换记录",//"EPK兑换记录",
  RSID.eerv_2:"转出交易",
  RSID.eerv_3:"转入交易",
  RSID.eerv_4:"失败原因",
  RSID.eerv_5:"重试提交兑换",
  RSID.eerv_6:"已重新提交",


  //Erc20ToEpkView   erc20转epk页面
  RSID.eev_1:"兑换记录",//"Swap records",
  RSID.eev_2:"发起兑换",
  RSID.eev_3:"确认交易",
  RSID.eev_4:"完成",
  RSID.eev_5:"兑换须知",
  RSID.eev_6:"以太坊上的 ERC20-EPK 和 EpiK Protocol 主网上的 EPK 可以 1:1 双向兑换，跨链桥由 EpiK Protocol 基金会提供。兑换过程中因跨链桥需要向以太坊缴纳高昂的交易手续费，所以会向每一笔兑换收取一定的 EPK 作为服务费。兑换完成后，您兑换获取的 EPK 或者 ERC20-EPK 将自动转入您当前的 EpiK 钱包，资产转入需要一段时间，请耐心等待。",
  RSID.eev_7:"风险提示",
  RSID.eev_8_1:"为避免您之前参与挖矿活动有意或者无意的泄露过当前钱包的助记词或私钥，强烈建议",
  RSID.eev_8_2:"创建新钱包",
  RSID.eev_8_3:"，将 ERC20-EPK 转入全新的钱包后，再进行兑换。",
  RSID.eev_9:"免责声明",
  RSID.eev_10:"如您通过其他渠道自行销毁了 ERC20-EPK 导致无法正常兑换 EPK，EpiK Protocol 基金会将不予赔偿",
  RSID.eev_11:"地址:",
  RSID.eev_12:"兑换数量",
  RSID.eev_13:"兑换为",
  RSID.eev_14:"最少兑换",
  RSID.eev_15:"最多兑换",
  RSID.eev_16:"手续费",
  RSID.eev_17:"已转出交易补领 EPK",
  RSID.eev_18:"已转出交易补领 ERC20-EPK",
  RSID.eev_19:"交易失败",
  RSID.eev_20:"TxHash 已复制",
  RSID.eev_21:"发起新的兑换",
  RSID.eev_22:"等待交易确认",
  RSID.eev_23_1:"如长时间不上链可以",
  RSID.eev_23_2:"加速交易",
  RSID.eev_24:"刷新",
  RSID.eev_25:"CID 已复制",
  RSID.eev_26:"兑换完成",
  RSID.eev_27_1:"请在",
  RSID.eev_27_2:"兑换记录",
  RSID.eev_27_3:"中查看到账情况",
  RSID.eev_28:"兑换数量限制",
  RSID.eev_29:"兑换已提交",
  RSID.eev_30:"请输入转出 ERC20-EPK 交易的 TxHash",
  RSID.eev_31:"提交失败",
  RSID.eev_32:"TxHash 查询失败",
  RSID.eev_33:"TxHash 无效",
  RSID.eev_34:"请输入转出 EPK 交易的 CID",
  RSID.eev_35:"CID 查询失败",
  RSID.eev_36:"CID无效",
  RSID.eev_37:"预计 6 - 15 分钟完成",
  RSID.eev_38:"预计 7 - 8 小时完成",

  RSID.er2ep_state_created:"已创建",
  RSID.er2ep_state_blocking:"打包中",
  RSID.er2ep_state_pending:"确认中",
  RSID.er2ep_state_recieved:"已到账",
  RSID.er2ep_state_paying:"支付中",
  RSID.er2ep_state_success:"成功",
  RSID.er2ep_state_failed:"失败",

  // dialog showEthAccelerateTx
  RSID.eatd_1:"加速交易",
  RSID.eatd_2:"输入加速交易的Gas比例",
  RSID.eatd_3:"请输入加速Gas比例",
  RSID.eatd_4:"Gas比例需要>1",
  RSID.eatd_5:"密码错误",
  RSID.eatd_6:"加速交易已提交",

  //BountyDappListView
  RSID.bdlv_1:"赏金猎人奖励",
  RSID.bdlv_2:"领取须知",
  RSID.bdlv_3_1:"赏金猎人奖励所需的 EPK 由 EpiK Protocol 知识基金提供。领取过程中，需要您提供",
  RSID.bdlv_3_2:"提供的领取令牌，领取金额有最小限额，只有余额大于最小限额才能领取。领取后您在对应应用内的 EPK 余额会减少，您领取的 EPK 将自动转入您当前的 EpiK 钱包。",
  RSID.bdlv_4:"风险提示",
  RSID.bdlv_5_1:"请确保您没有泄露当前钱包助记词和私钥，否则强烈建议",
  RSID.bdlv_5_2:"创建新钱包",
  RSID.bdlv_5_3:"，在新钱包中进行领取。",

  //BountyDappTakeRecordView
  RSID.bdtrv_1:"领取记录",
  RSID.bdtrv_2:"EPK 发放交易",

  //BountyDappTakeView
  RSID.bdtv_1:"数量需要大于",//
  RSID.bdtv_2:"领取数量",
  RSID.bdtv_3:"手续费: ",
  RSID.bdtv_4:"账号: ",
  RSID.bdtv_5:"名称: ",
  RSID.bdtv_6:"确认领取",
  RSID.bdtv_7:"确认领取后会提交领取申请，审核通过后会发放EPK到您当前的钱包",
  RSID.bdtv_8:"领取EPK",
  RSID.bdtv_9:"已提交领取申请，审核通过后将发放到您当前钱包，请在领取记录中查看。",
  RSID.bdtv_10:"领取",
  RSID.bdtv_11:"绑定",
  RSID.bdtv_12:"请输入兑换令牌",
  RSID.bdtv_13:"解绑",
  RSID.bdtv_14:"您确定要解绑%s账号的兑换令牌吗？",
  RSID.bdtv_15:"最小数量为",

  //OwnerListView
  RSID.olv_1:"余额",
  RSID.olv_2:"我的流量质押",
  RSID.olv_3:"增加",
  RSID.olv_4:"赎回",
  RSID.olv_5:"流量",
  RSID.olv_6:"节点数",
  RSID.olv_7:"总流量质押",

  //minerListView
  RSID.mlv_1:"批量操作",
  RSID.mlv_2:"取消批量操作",
  RSID.mlv_3:"已绑定",
  RSID.mlv_4:"未绑定",
  RSID.mlv_5:"基础质押",
  RSID.mlv_6:"我的质押",
  RSID.mlv_7:"有效算力",
  RSID.mlv_8:"节点收益",
  RSID.mlv_9:"全部质押",
  RSID.mlv_10:"批量赎回",
  RSID.mlv_11:"已选择节点",
  RSID.mlv_12:"全部",
  RSID.mlv_13:"我的 CoinBase",
  RSID.mlv_14:"已质押",
  RSID.mlv_15:"激活中",
  RSID.mlv_16:"0算力",
  RSID.mlv_17:"未质押",
  RSID.mlv_18:"其它 CoinBase",
  RSID.mlv_19:"低算力",
  RSID.mlv_20:"申请赎回抵押交易已提交",
  RSID.mlv_21:"转移",
  RSID.mlv_22:"质押转移",
  RSID.mlv_23:"请输入目标NodeID",
  RSID.mlv_24:"质押转移交易已提交",
  RSID.mlv_25:"赎回",// apply withdraw
  RSID.mlv_26:"批量提现",//
  RSID.mlv_27:"请输入金额",
  RSID.mlv_28:"算力",
  RSID.mlv_28_1:"算力升序",
  RSID.mlv_28_2:"算力降序",
  RSID.mlv_29:"收益",
  RSID.mlv_29_1:"收益升序",
  RSID.mlv_29_2:"收益降序",
  RSID.mlv_30:"ID",
  RSID.mlv_30_1:"ID升序",
  RSID.mlv_30_2:"ID降序",
  RSID.mlv_31:"质押",
  RSID.mlv_32:"复制NodeID",
  RSID.mlv_33:"请输入%s个目标NodeID，使用\",\"或空格分隔。",
  RSID.mlv_34:"输入的NodeID数量与选中的不一致",
  RSID.mlv_35:"批量转移质押",
  RSID.mlv_36:"我质押的",//"Pledged By Me",//
  RSID.mlv_37:"别人质押的",//"Pledged By Others",//

  ///AddOtherOwnerPledgeView
  RSID.aoopv_1:"新增Owner",
  RSID.aoopv_2:"流量质押数量",
  RSID.aoopv_3:"增加流量质押",
  RSID.aoopv_4:"请输入OwnerID",

  ///AddOtherMinerPledgeView
  RSID.aompv_1:"新增节点",
  RSID.aompv_2:"节点质押数量",
  RSID.aompv_3:"增加节点质押",
  RSID.aompv_4:"请输入NodeID",

  //RemoteAuthView
  RSID.rav_1:"远程授权",
  RSID.rav_2:"待授权数据",
  RSID.rav_3:"原文",
  RSID.rav_4:"接口",
  RSID.rav_5:"确认授权",
  RSID.rav_6:"授权成功",
  RSID.rav_7:"授权失败",

  //web3
  RSID.Web3Menu_REFRESH:"刷新",
  RSID.Web3Menu_CLEARCACHE:"清除缓存",
  RSID.Web3Menu_COLLECT:"收藏",
  RSID.Web3Menu_GAS:"预设Gas",
  RSID.Web3Menu_KEEP_PASSWORD:"免密交易",
  RSID.gasrate:"加倍 : ",
  RSID.w3wv_auth_keep_password:"交易时不用再次输入密码，但每次交易还需要确认才可以进行。是否临时授权当前站点%s可以预设交易密码？",
  RSID.w3wv_canceled:"已取消",//canceled
  RSID.w3wv_authorized:"已授权",
  RSID.w3wv_added:"已添加收藏",
  RSID.w3wv_deteled:"已取消收藏",
  RSID.w3wv_network:"网络",
  RSID.w3wv_switch_chain:"允许此站点切换网络？",

  //地址列表
  RSID.address_list:"地址列表",//地址列表
  RSID.no_address_available:"暂无可用地址",
  RSID.alv_addnew:"添加新地址",
  RSID.alv_edit:"编辑",
  RSID.alv_batch:"批量",
  RSID.alv_delete:"删除",
  RSID.alv_delete_ask:"是否要删除这个地址?",
  RSID.alv_name:"名称",
  RSID.alv_input_name:"请输入名称",
  RSID.alv_address:"地址",
  RSID.alv_select_currency:"请选择币种",// Please select a currency
  RSID.alv_input_address:"请输入正确的钱包地址",//
  RSID.alv_select_address:"选择地址",//
  RSID.alv_withdraw_to_self:"不能给自己当前钱包地址转账",

  //CurrencyBatchWithdrawView
  RSID.cbwv_1:"总金额",//"Transfer Amount",
  RSID.cbwv_2:"输入总金额会平均到所有地址",

  //HomeMenuMoreView
  RSID.hmmv_1:"添加",
  RSID.hmmv_2:"批量",
  RSID.hmmv_3:"添加新网站",
  RSID.hmmv_4:"编辑",
  RSID.hmmv_5:"网址",
  RSID.hmmv_6:"请输入以http://或https://开头的网址",
  RSID.hmmv_7:"删除",

  //AndroidWebPermission
  RSID.awp_permission_request:"权限申请",
  RSID.awp_ask:"网站请求以下权限，是否授权？",//The website requests the following permissions. Do you want  grant
  RSID.awp_deny:"拒绝",
  RSID.awp_grant:"授权",
  RSID.awp_audio:"录音",
  RSID.awp_midisysex:"连接MIDI设备通信",
  RSID.awp_media:"访问媒体库",
  RSID.awp_video:"录像",

  //Biometrics
  RSID.biometrics:"生物特征认证",
  RSID.biometrics_faceid:"面部识别",
  RSID.biometrics_fingerprint:"指纹识别",

  RSID.biometrics_localizedReason:"请扫描指纹或面部",//Scan your fingerprint (or face or whatever) to authenticate

  RSID.biometrics_signInTitle:"身份验证", //Authentication Required
  RSID.biometrics_biometricHint:"",//
  RSID.biometrics_biometricNotRecognized:"验证失败, 再试一次。",//"Not recognized, try again.",
  RSID.biometrics_biometricSuccess:"验证成功", //"Success"
  RSID.biometrics_cancelButton:"取消", //"Cancel"
  RSID.biometrics_biometricRequiredTitle: "验证要求", //"Biometric required",
  RSID.biometrics_goToSettingsButton: "去设置",//"Go to settings",
  RSID.biometrics_goToSettingsDescription:"您的设备没有开启此功能, 请到\"设置 > 安全\"中设置。",//Biometric authentication is not set up on your device. Go to \'Settings > Security\' to add biometric authentication.

  RSID.biometrics_ioslockOut:"生物认证被禁用。请锁定再解锁您的屏幕启用它。", //'Biometric authentication is disabled. Please lock and unlock your screen to enable it.',
  RSID.biometrics_iosgoToSettingsButton: "去设置", //"Go to settings",
  RSID.biometrics_iosgoToSettingsDescription: "您的设备上没有设置生物认证。请在您的手机上启用Touch ID或Face ID。", //'Biometric authentication is not set up on your device. Please either enable Touch ID or Face ID on your phone.',
  RSID.biometrics_ioscancelButton: "好的", // "OK"

  //nodepool
  RSID.nodepool_title:"租赁节点",//"节点池",
  RSID.nodepool_create:"创建节点池",
  RSID.nodepool_edit:"编辑",
  RSID.nodepool_confirm_edit:"确定修改",//Confirm modification
  RSID.nodepool_node_apy:"年化收益率",
  RSID.nodepool_node_count:"总节点",
  RSID.nodepool_node_actived:"运行中",
  RSID.nodepool_node_available:"可用",
  RSID.nodepool_node_lock:"已锁定",
  RSID.nodepool_node_own:"自己的",
  RSID.nodepool_node_rent:"租赁节点",
  RSID.nodepool_node_manage:"管理",
  RSID.nodepool_node_insufficient_epk:"EPK余额不足",//nsufficient EPK balance
  RSID.nodepool_node_locked:"申请节点成功！\n节点ID：%s（已复制到剪切板）\n请在1小时内完成质押，超时将被释放。",
  RSID.nodepool_node_abort:"稍后质押",
  RSID.nodepool_node_palde:"立刻质押",
  RSID.nodepool_node_poolmanage:"管理节点池",

  //NodePoolCreateView
  RSID.npcv_1:"名称",
  RSID.npcv_2:"请输入名称",
  RSID.npcv_3:"描述",
  RSID.npcv_4:"请输入描述",
  RSID.npcv_5:"EPK费用地址",
  RSID.npcv_6:"请输入EPK费用地址",
  RSID.npcv_7:"费用比例",
  RSID.npcv_8:"节点池状态",//"是否可用",
  RSID.npcv_9:"开启",
  RSID.npcv_10:"停用",
  RSID.npcv_11:"请设费用比例",
  RSID.npcv_12:"已创建",
  RSID.npcv_13:"已保存",

  //NodePoolManageView
  RSID.npmv_1:"添加Owner",
  RSID.npmv_2:"删除",
  RSID.npmv_3:"提交需要转移质押的节点，节点用户会依据这些记录转移质押到目标节点。",
  RSID.npmv_4:'输入原MinerID 多个用","分隔',
  RSID.npmv_5:'输入目标MinerID 多个用","分隔',
  RSID.npmv_6:"MinerID数量需要相同",
  RSID.npmv_7:"已提交",
  RSID.npmv_8:"变更节点",

  //NodePoolAddOwnerView
  RSID.npaov_1:"请输入OwnerID",
  RSID.npaov_2:"请复制上述代码，在epik daemon上签名，并将签名粘贴到下方。",//"请复制上述代码，在EpiK miner上签名，并将签名粘贴到下方。",
  RSID.npaov_3:"签名数据",
  RSID.npaov_4:"请输入签名数据",
  RSID.npaov_5:"已添加",

  //RentNodeNeedTransferView
  RSID.rnntv_1:"租赁节点需要转移",
  RSID.rnntv_2:"待转移节点",
};
