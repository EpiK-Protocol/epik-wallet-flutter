import 'package:epikwallet/localstring/resstringid.dart';

// 中文字符表
Map<RSID, String> map_zh = {
  //base
  RSID.doubleclickquit: "再按一次退出",
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
  RSID.content_empty: "暂无数据",
  RSID.no_more: "没有更多了",
  RSID.net_error: "网络错误",
  RSID.takephoto: "拍照",
  RSID.gallery: "相册",

  //----------------------------------------dialog.*
  //BottomDialog
  RSID.dlg_bd_1: "钱包密码",
  RSID.dlg_bd_2: "请输入钱包密码",
  RSID.dlg_bd_3: "请输入密码",
  RSID.dlg_bd_4: "密码不正确",

  //----------------------------------------views.wallet.*
  //ImportWalletView 导入钱包
  RSID.iwv_1: "导入EpiK Portal钱包",
  RSID.iwv_2: "请备份好您的密码！EpiK Portal不存储用户密码，无法提供找回或重置的服务。",
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
  RSID.iwv_20: "导入失败钱包失败",

  //ExportEpikPrivateKeyView 导出私钥
  RSID.eepkv_1: "导出tEPK私钥",
  RSID.eepkv_2: "已复制私钥",
  RSID.eepkv_3: "复制私钥",

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
  RSID.mainview_4: "赏金",

  //MiningView 首页_挖矿
  RSID.main_mv_1: "预挖排行",
  RSID.main_mv_2: "预挖总奖励",
  RSID.main_mv_3: "已发放奖励",
  RSID.main_mv_4: "已复制ID",
  RSID.main_mv_5: "累计奖励: ",
  RSID.main_mv_6: "报名",
  RSID.main_mv_7: "审核中",
  RSID.main_mv_8: "预挖奖励",
  RSID.main_mv_9: "报名已被拒绝",

  //WalletView 首页_钱包
  RSID.main_wv_1: "没有钱包",
  RSID.main_wv_2: "创建钱包",
  RSID.main_wv_3: "已有钱包",
  RSID.main_wv_4: "导入钱包",

  //WalletMenu 首页_钱包侧滑菜单
  RSID.main_mw_1: "钱包",
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

  //----------------------------------------views.mining.*
  //MiningProfitView 预挖收益
  RSID.mpv_1: "预挖收益",
  RSID.mpv_2: "挖出数量\ntEPK",
  RSID.mpv_3: "奖励数量\nERC20-EPK",

  //MiningSignupView 预挖报名
  RSID.msv_1: "预挖报名",
  RSID.msv_2: "已复制客服微信号\n请在微信添加好友",
  RSID.msv_3: "报名前请先使用要绑定的微信号添加客服微信",
  RSID.msv_4: "，成功报名后将显示的UUID发送给客服微信。",
  RSID.msv_5:
      "本次测试活动由铭识协议基金会监督，最终解释权归铭识协议基金会所有 ，参与本次活动视为接受以下规定： 铭识协议基金会保留在测试中任何时刻修改、完善和增加测试活动或测试规则的权力，并在测试期间及测试结束后任何时刻均有权取消包括且不限于试图或有嫌疑利用、欺诈、恶意攻击网络的参赛者参赛权益和已获得挖矿奖励。辱骂、威胁主办方，铭识协议基金会保留取消参赛者参赛权益和已获得挖矿奖励的权力。",
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
  //CurrencyWithdrawView 转账
  RSID.cwv_1: "转出地址",
  RSID.cwv_2: "接收地址",
  RSID.cwv_3: "输入地址、长按粘贴地址或点扫描二维码",
  RSID.cwv_4: "转账金额",
  RSID.cwv_5: "全部",
  RSID.cwv_6: "输入金额",
  RSID.cwv_7: "手续费 : %s eth",
  RSID.cwv_8: "请填入接收地址",
  RSID.cwv_9: "请输入金额",
  RSID.cwv_10: "转账金额不能是0",
  RSID.cwv_11: "转账失败",
  RSID.cwv_12: "操作成功!",

  //----------------------------------------views.qrcode.*
  //QrcodeScanView 扫描二维码
  RSID.qsv_1: "扫一扫",

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
  RSID.uspv_15_1:
      "「1」本页资金池交易是基于Uniswap的ERC20-EPK与USDT的流动性支持\n\n「2」底层部署在以太坊公链上，兑换及资金池操作均会产生ETH手续费，操作前请确保钱包有足够的ETH。\n\n「3」官方智能合约地址为：",
  RSID.uspv_15_2: "\n\n「4」新手操作说明请点击",
  RSID.uspv_15_3: "这里",
  //UniswapExchangeView
  RSID.usev_1: "预估",
  RSID.usev_2: "手续费 : %s eth",
  RSID.usev_3: "滑点 : %s%",
  RSID.usev_4: "余额:",
  RSID.usev_5: "全部",
  RSID.usev_6: "需要预估数量",
  RSID.usev_7: "请输入%s数量",
  RSID.usev_8: "数量不能为0",
  RSID.usev_9: "正在预估数量...",
  RSID.usev_10_1:
      "「1」本页兑换交易是基于Uniswap的ERC20-EPK与USDT交易\n\n「2」底层部署在以太坊公链上，兑换及资金池操作均会产生ETH手续费，操作前请确保钱包有足够的ETH。\n\n「3」官方智能合约地址为：",
  RSID.usev_10_2: "\n\n「4」新手操作说明请点击",
  RSID.usev_10_3: "这里",
  RSID.usev_11: "正在提交到以太坊网络，请耐心等待",
  RSID.usev_12: "已提交到以太坊\n稍后可在交易记录中查询结果",
  //UniswapPoolAddView 注入资金
  RSID.uspav_1: "当前为预估价格，如果价格波动超过%s%，您的交易将会撤销。",
  RSID.uspav_2: "手续费 : %s eth",
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
  RSID.bexv_15:
      "「1」用积分兑换ERC20-EPK时，通过以太网转账会产生ETH手续费；\n\n「2」手续费数量是根据以太坊gas费用和Uniswap中的币价计算出要扣除多少ERC20-EPK。",
  RSID.bexv_16: "当前绑定Telegram：",

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
};
