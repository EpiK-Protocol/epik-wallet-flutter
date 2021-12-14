import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/main.dart';

extension RSID_ex on RSID {
  String get text {
    return ResString.get(appContext, this);
  }

  String replace(List<String> replace)
  {
    return ResString.get(appContext, this,replace: replace);
  }
}

enum RSID {
  //base
  doubleclickquit,
  copy,
  copied,
  tip,
  confirm,
  cancel,
  last_step,
  next_step,
  isee,
  upgrade_tip,
  upgrade_des,
  upgrade_des_1,
  upgrade_des_2,
  upgrade_confirm,
  upgrade_cancel,
  completed,
  request_failed,
  request_failed_retry,
  request_failed_retry_click,
  request_failed_checknetwork,//Data loading failed. Please check the network.
  content_empty,
  no_more,
  net_error,
  takephoto,
  gallery,
  unknown,
  request_error,//请求错误
  network_exception,//网络异常
  network_exception_retry,//网络异常,请稍后重试  "Request failed. Please try again later.",
  connect_timeout,//连接超时
  cancel_request,//取消请求 Cancel request
  retry,

  //----------------------------------------dialog.*
  //BottomDialog
  dlg_bd_1,
  dlg_bd_2,
  dlg_bd_3,
  dlg_bd_4,
  dlg_bd_5,

  //----------------------------------------views.wallet.*
  //ImportWalletView 导入钱包
  iwv_1,
  iwv_2,
  iwv_3,
  iwv_4,
  iwv_5,
  iwv_6,
  iwv_7,
  iwv_8,
  iwv_9,
  iwv_10,
  iwv_11,
  iwv_12,
  iwv_13,
  iwv_14,
  iwv_15,
  iwv_16,
  iwv_17,
  iwv_18,
  iwv_19,
  iwv_20,
  //ExportEpikPrivateKeyView 导出私钥
  eepkv_1,
  eepkv_2,
  eepkv_3,
  eepkv_4,
  eepkv_5,
  eepkv_6,
  eepkv_7,
  //AccountDetailView 钱包账号详情
  adv_1,
  adv_2,
  adv_3,
  adv_4,
  //FixPasswordView 修改密码
  fpv_1,
  fpv_3,
  fpv_4,
  fpv_5,
  //CreateWalletView 创建钱包
  cwtv_1,
  cwtv_2,
  //CreateMnemonicView 创建助记词
  cmv_1,
  cmv_2,
  cmv_3,
  cmv_4,
  //VerifyMnemonicView 验证助记词
  vmv_1,
  vmv_2,
  vmv_3,
  vmv_4,
  vmv_5,
  vmv_6,
  vmv_7,
  //VerifyCreatePasswordView 验证创建的密码
  vcpv_1,
  vcpv_2,
  vcpv_3,
  vcpv_4,
  vcpv_5,

  //----------------------------------------views.*
  //MainView 首页框架
  mainview_1,
  mainview_2,
  mainview_3,
  mainview_4,
  mainview_5,
  mainview_6,
  //MiningView 首页_挖矿
  main_mv_1,
  main_mv_2,
  main_mv_3,
  main_mv_4,
  main_mv_5,
  main_mv_6,
  main_mv_7,
  main_mv_8,
  main_mv_9,
  //WalletView 首页_钱包
  main_wv_1,
  main_wv_2,
  main_wv_3,
  main_wv_4,
  main_wv_5,
  main_wv_6, //总资产
  main_wv_7, //ERC20-EPK 兑换 EPK
  main_wv_8, //领取赏金猎人奖励
  main_wv_9, //ERC20-EPK Uniswap 交易
  main_wv_10, //暂未开通
  main_wv_11,//钱包设置
  //WalletMenu 首页_钱包侧滑菜单
  main_mw_1,
  main_mw_2,
  main_mw_3,
  main_mw_4,
  main_mw_5,
  main_mw_6,
  //TransactionView 首页_交易
  main_tv_1,
  //BountyView 首页_赏金
  main_bv_1,
  main_bv_2,
  main_bv_3,
  main_bv_4,
  main_bv_5,
  main_bv_6,
  main_bv_7,
  main_bv_8,
  main_bv_9,
  main_bv_10,
  main_bv_11,
  main_bv_12,
  main_bv_13,
  main_bv_14,

  //----------------------------------------views.mining.*
  //MiningProfitView 预挖收益
  mpv_1,
  mpv_2,
  mpv_3,
  mpv_4,
  //MiningSignupView 预挖报名
  msv_1,
  msv_2,
  msv_3,
  msv_4,
  msv_5,
  msv_6,
  msv_7,
  msv_8,
  msv_9_1,
  msv_9_2,
  msv_10,
  msv_11,
  msv_12,
  msv_13,
  msv_14,
  msv_15,
  msv_16,
  msv_17,
  msv_18,
  msv_19,
  msv_20,

  //----------------------------------------views.currency.*
  //CurrencyDetailView 币详情
  withdraw,
  deposit,
  //CurrencyDepositView 收款
  cdv_1,
  cdv_2,
  cdv_3,
  cdv_4,
  cdv_5,
  cdv_6,
  cdv_7,
  cdv_8,
  //CurrencyWithdrawView 转账
  cwv_1,
  cwv_2,
  cwv_3,
  cwv_4,
  cwv_5,
  cwv_6,
  cwv_7,
  cwv_8,
  cwv_9,
  cwv_10,
  cwv_11,
  cwv_12,
  cwv_13,
  cwv_14,

  //----------------------------------------views.qrcode.*
  //QrcodeScanView 扫描二维码
  qsv_1,
  qsv_2,
  qsv_3,

  //----------------------------------------views.uniswap.*
  //UniswapView 外壳
  usv_1,
  usv_2,
  usv_3,
  //UniswapPoolView 资金池
  uspv_1,
  uspv_2,
  uspv_3,
  uspv_4,
  uspv_5,
  uspv_6,
  uspv_7,
  uspv_8,
  uspv_9,
  uspv_10,
  uspv_11,
  uspv_12,
  uspv_13,
  uspv_14,
  uspv_15_1,
  uspv_15_2,
  uspv_15_3,
  //UniswapExchangeView 兑换
  usev_1,
  usev_2,
  usev_3,
  usev_4,
  usev_5,
  usev_6,
  usev_7,
  usev_8,
  usev_9,
  usev_10_1,
  usev_10_2,
  usev_10_3,
  usev_11,
  usev_12,
  usev_13,
  usev_14,
  usev_15,
  //UniswapPoolAddView 注入资金
  uspav_1,
  uspav_2,
  uspav_3,
  uspav_4,
  uspav_5,
  uspav_6,
  //UniswapPoolRemoveView 撤回资金
  usprv_1,
  usprv_2,
  usprv_3,
  usprv_4,
  //UniswaporderlistView 交易记录
  usolv_1,
  usolv_2,
  usolv_3,

  //----------------------------------------views.bounty.*
  //BountyDetailView 悬赏任务详情
  bdv_1,
  bdv_2,
  bdv_3,
  bdv_4,
  bdv_5,
  bdv_6,
  bdv_7,
  bdv_8,
  bdv_9,
  bdv_10,
  bdv_11,
  bdv_12,
  bdv_13,
  bdv_14,
  bdv_15,
  bdv_16,
  //BountyEditView 编辑奖励
  bev_1,
  bev_2,
  bev_3,
  bev_4,
  bev_5,
  bev_6,
  bev_7,
  bev_8,
  //BountyExchangeRecordListview 兑换记录
  berlv_1,
  berlv_2,
  berlv_3,
  berlv_4,
  //BountyRewardRecordListview 积分奖励记录
  brrlv_1,
  //BountyExchangeView 积分兑换
  bexv_1,
  bexv_2,
  bexv_3,
  bexv_4,
  bexv_5,
  bexv_6,
  bexv_7,
  bexv_8,
  bexv_9,
  bexv_10,
  bexv_11,
  bexv_12,
  bexv_13,
  bexv_14,
  bexv_15,
  bexv_16,
  bexv_17,
  bexv_18,
  bexv_19,
  bexv_20,
  bexv_21,

  //----------------------------------------logic.*
  //UniswapHistoryMgr.dart
  uhm_1,
  uhm_2,
  uhm_3,
  //BountyTask.dart
  bts_1,
  bts_2,
  bts_3,
  bts_4,
  bts_5,
  bts_6,
  bts_7,
  bts_8,
  bts_9,
  bts_10,
  //BountyUserReward.dart
  bur_1,
  //BountyUserSwap.dart
  bus_1,
  bus_2,
  bus_3,
  bus_4,

  //----------------------------------------MinerView
  minerview_1, //抵押
  minerview_2, //赎回
  minerview_3, //请输入MinerID
  minerview_4, //添加
  minerview_5, //存储矿工
  minerview_6, //当前算力
  minerview_7, //账户余额
  minerview_8, //锁定余额
  minerview_9, //可提余额
  minerview_10, //矿工基础抵押
  minerview_11, //我的基础抵押
  minerview_12, //流量抵押余额
  minerview_13, //流量抵押锁定
  minerview_14, //当日访问流量
  minerview2_1, //总余额
  minerview2_2, //锁定中
  minerview2_3, //已解锁
  minerview2_4, //提现
  minerview2_5,// 总算力
  minerview2_6,// 总质押
  minerview2_7,// 节点质押
  minerview2_8,// 流量质押
  minerview2_9,//节点数据
  minerview2_10,//查看全部节点
  minerview2_11,//节点总数
  minerview2_12,//激活节点
  minerview2_13,//算力不足
  minerview2_14,//错误节点
  minerview2_15,//已质押
  minerview2_16,//我的质押
  minerview2_17,//流量
  minerview2_18,//查看 Owner
  minerview2_19,//总流量质押
  minerview2_20,//我的流量质押


  //---add
  minerview_15, //注意：\n- 知识矿工需要启动实体矿机才能参与挖矿\n- 知识矿工需要完成1000EPK的矿工基础抵押才能获得出块资格\n- 知识矿工需要从网络里读取新文件，存储新文件才能增加算力，增大出块概率 \n- 1EPK=10Mb的每日访问流量，每日已用访问流量将会返还\n- 您可以在任何时候赎回抵押的EPK
  minerview_16, // EPK 可用
  minerview_17, //访问流量抵押
  minerview_18, //交易已提交
  minerview_19, //查看交易
  minerview_20, //添加抵押交易已提交
  //---withdraw
  minerview_21, //注意：\n- 仅能赎回自己抵押的EPK\n- 如果你当前已经消耗了一部分访问流量，则无法赎回全部的访问流量抵押，请尝试减少赎回的数量\n- 矿工基础抵押赎回中的EPK将会立刻到账\n- 访问流量抵押的EPK需要在解锁操作3天后才能赎回\n
  minerview_22, // EPK 可赎回
  minerview_23, // EPK 可解锁
  minerview_24, // 解锁
  minerview_25, //访问流量抵押
  minerview_26, //赎回抵押交易已提交
  minerview_27, //解锁抵押交易已提交
  minerview_28,//我的流量抵押
  minerview_29,//剩余高度
  minerview_30,//"Coinbase提取",
  //---MinerMenu
  minermenu_1, //选择MinerID
  minermenu_2, //删除MinerID
  minermenu_3, //删除
  minermenu_4, //添加MinerID
  minermenu_5, //请输入MinerID
  minermenu_6, //一键抵押
  minermenu_7, //一键抵押
  minermenu_8, //一键抵押

  //----------------------------------------ExpertView
  expertview_1, //全部
  expertview_2, //领域专家
  expertview_3, //当前年化收益
  expertview_4, //已投
  expertview_5, //累计收益
  expertview_6, //申请成为领域专家
  expertview_7, //领域
  expertview_8, //收益
  expertview_9, //已注册//registered
  expertview_10, //已审核//nominated
  expertview_11, //活跃的//normal
  expertview_12, //黑名单//blocked
  expertview_13, //黑名单//disqualified
  expertview_14, //可提现收益
  expertview_15, //请输入提取数量
  expertview_16, //"当前没有收益可提取",
  expertview_17, //您已投出
  expertview_18, //解锁中
  expertview_19, //已解锁

  //ApplyExpertView
  applyexpertview_1, //申请领域专家
  applyexpertview_2, //您的申请已提交，请等待审核结果。
  applyexpertview_3, //再次申请
  applyexpertview_4, //您的申请已通过
  applyexpertview_5, //申请须知
  applyexpertview_6, //费用
  applyexpertview_7, //提交申请
  applyexpertview_8, //请输入姓名
  applyexpertview_9, //请输入手机号
  applyexpertview_10, //请输入邮箱
  applyexpertview_11, //请输入领域
  applyexpertview_12, //请输入个人介绍
  applyexpertview_13, //很遗憾，您的申请未通过。
  applyexpertview_14, //原因
  applyexpertview_15, //您可以更新申请表重新提交审核
  applyexpertview_16, //姓名
  applyexpertview_17, //手机号(非公开)
  applyexpertview_18, //邮箱(非公开)
  applyexpertview_19, //想申请的领域
  applyexpertview_20, //请从教育背景，工作经历，影响力等方面介绍自己
  applyexpertview_21, //个人介绍(公开)
  applyexpertview_22, //知识图谱数据默认遵循无任何限制的开源协议，如对开源协议有任何特殊要求，请填写如下（选填）
  applyexpertview_23, //开源协议(公开)
  applyexpertview_24, //交易确认中
  applyexpertview_25, //领域专家申请已提交，请等待审核。
  applyexpertview_26,//语言
  applyexpertview_27,//推特
  applyexpertview_28,//领英
  applyexpertview_29,//为什么你是这个领域的合适人选？ Why are you the right person of this domain?
  applyexpertview_30,//您将如何根据该领域收集的数据开发或推广应用程序？你会如何推动AI应用来使用这个领域的数据并从中获益？How will you develop or promote the applications to be nefit from the data collected in this domain?
  applyexpertview_31,//基础信息 Basic Infomation
  applyexpertview_32,//告诉大家你是谁 Please tell all EPKers who you are.
  applyexpertview_33,//专业介绍 Professional Introduction
  applyexpertview_34,//请选择一个领域，并结合您自己的经验告诉大家您是该领域专家最适合的人选。 Please choose one domain and combine your own experience to tell all EPKers that you are the right person to be the domain expert in this domain.
  applyexpertview_35,//人工智能应用程序 AI Application
  applyexpertview_36,//请告诉大家，该领域中的数据将非常有用，您可以开发一个新的AI应用程序或找到一个现有的AI应用程序，以使该领域中的数据受益。 Please tell all EPKers that the data in this domain will be very useful and you could develop a new AI application or find an existing AI application to benefit the data in this domain.
  applyexpertview_37, //请选择语言
  applyexpertview_38, //请输入推特
  applyexpertview_39, //请选择领英
  applyexpertview_40, //请输入为什么您是合适人选
  applyexpertview_41, //请输入您怎么开发或使用现有人工智能应用
  applyexpertview_42,//为什么我能做好这个领域？
  applyexpertview_43,//我会如何推动AI应用来使这个领域中的数据收益

  //ExpertInfoView
  expertinfoview_0, //领域专家详情
  expertinfoview_1, //个人简介
  expertinfoview_2, //开源协议
  expertinfoview_3, //状态
  expertinfoview_4, //投票
  expertinfoview_5, //收益
  expertinfoview_6, //已投
  expertinfoview_7, //请输入数额
  expertinfoview_8, //追加投票
  expertinfoview_9, //撤回投票
  expertinfoview_10, //提取EPK
  expertinfoview_11, //请输入数量
  expertinfoview_12, //已投票
  expertinfoview_13, //已撤回
  expertinfoview_14, //已提取
  expertinfoview_15, //查看


  // Erc20ToEpkRecordView  erc20转epk 兑换记录
  eerv_1,//EPK兑换记录
  eerv_2,//转出交易
  eerv_3,//转入交易
  eerv_4,//失败原因
  eerv_5,//重试提交兑换
  eerv_6,//已重新提交

  //Erc20ToEpkView   erc20转epk页面
  eev_1,//"兑换记录",//"Swap records",
  eev_2,//发起兑换
  eev_3,//确认交易
  eev_4,//完成
  eev_5,//兑换须知
  eev_6,//此次兑换所需的EPK有EpiK基金会提供。兑换过程中，需要您发起一笔以太坊交易，所以请确保您当前账户内有足够的以太坊支付此笔交易的手续费。兑换后，您当前以太坊钱包中的所有ERC20-EPK将会销毁，并按照1:1的比例兑换得到EPK，这些EPK将自动转入您当前EpiK钱包。
  eev_7,//风险提示
  eev_8_1,//为避免您之前参与挖矿活动有意或者无意的泄露过当前钱包的助记词或私钥，强烈建议
  eev_8_2,//创建新钱包
  eev_8_3,//，将ERC20-EPK转入全新的钱包后，再进行兑换。
  eev_9,//免责声明
  eev_10,//如您通过其他渠道自行销毁了ERC20-EPK导致无法正常兑换EPK，EpiK基金会将不予赔偿
  eev_11,//地址:
  eev_12,//兑换数量
  eev_13,//兑换成
  eev_14,//最少兑换
  eev_15,//最多兑换
  eev_16,//手续费
  eev_17,//已转出交易补领EPK
  eev_18,//已转出交易补领ERC20-EPK
  eev_19,//交易失败
  eev_20,//TxHash已复制
  eev_21,//发起新的兑换
  eev_22,//等待交易确认
  eev_23_1,//如长时间不上链可以
  eev_23_2,//加速交易
  eev_24,//刷新
  eev_25,//cid已复制
  eev_26,//兑换完成
  eev_27_1,//请在
  eev_27_2,//兑换记录
  eev_27_3,//中查看到账情况
  eev_28,//兑换数量限制
  eev_29,//兑换已提交
  eev_30,//请输入转出ERC20-EPK交易的TxHash
  eev_31,//提交失败
  eev_32,//TxHash查询失败
  eev_33,//TxHash无效
  eev_34,//请输入转出EPK交易的cid
  eev_35,//cid查询失败
  eev_36,//cid无效
  eev_37,//预计 6 - 15 分钟完成
  eev_38,//预计 7 - 8 小时完成

  er2ep_state_created, //已创建
  er2ep_state_blocking, //等待确认
  er2ep_state_pending, //确认中
  er2ep_state_recieved, //已到账
  er2ep_state_paying, //支付中
  er2ep_state_success, //成功
  er2ep_state_failed, //失败

  // dialog showEthAccelerateTx
  eatd_1,//加速交易
  eatd_2,//输入加速交易的Gas比例
  eatd_3,//请输入加速Gas比例
  eatd_4,//Gas比例需要>1
  eatd_5,//密码错误
  eatd_6,//加速交易已提交


  //BountyDappListView
  bdlv_1,//赏金猎人奖励
  bdlv_2,//领取须知
  bdlv_3_1,//赏金猎人奖励所需的EPK有EpiK知识基金提供。领取过程中，需要您提供
  bdlv_3_2,//提供的领取令牌，领取金额有最小限额，只有余额大于最小限额才能领取。领取后您在知识大陆的EPK余额会减少，您领取的EPK将自动转入您当前的EpiK钱包。
  bdlv_4,//风险提示
  bdlv_5_1,//请确保您没有泄露当前钱包助记词和私钥，否则强烈建议
  bdlv_5_2,//创建新钱包
  bdlv_5_3,//，在新钱包中进行领取。

  //BountyDappTakeRecordView
  bdtrv_1,//领取记录
  bdtrv_2,//EPK 发放交易

  //BountyDappTakeView
  bdtv_1,//数量需要大于
  bdtv_2,//领取数量
  bdtv_3,//手续费:
  bdtv_4,//账号:
  bdtv_5,//名称:
  bdtv_6,//确认领取
  bdtv_7,//确认领取后会提交领取申请，审核通过后会发放EPK到您当前的钱包
  bdtv_8,//领取EPK
  bdtv_9,//已提交领取申请，审核通过后将发放到您当前钱包，请在领取记录中查看。
  bdtv_10,//领取
  bdtv_11,//绑定
  bdtv_12,//请输入Dapp的令牌
  bdtv_13,//解绑
  bdtv_14,//您确定要解绑%s账号的令牌吗？
  bdtv_15,//数量需要大于

  //OwnerListView
  olv_1,//"余额",
  olv_2,//:"我的流量质押",
  olv_3,//:"添加",
  olv_4,//:"赎回",
  olv_5,//:"流量",
  olv_6,//:"节点数",
  olv_7,//:"总流量质押",

  //minerListView
  mlv_1,//批量操作
  mlv_2,//取消批量操作
  mlv_3,//已绑定
  mlv_4,//未绑定
  mlv_5,//基础质押
  mlv_6,//我的质押
  mlv_7,//有效算力
  mlv_8,//节点收益
  mlv_9,//全部质押
  mlv_10,//批量赎回
  mlv_11,//已选择节点
  mlv_12,//全部
  mlv_13,//我的CoinBase
  mlv_14,//已质押
  mlv_15,//激活中
  mlv_16,//0算力
  mlv_17,//未质押
  mlv_18,//其他CoinBase
  mlv_19,//低算力
  mlv_20,//"申请赎回抵押交易已提交",
  mlv_21,//"转移"",
  mlv_22,//"质押转移",
  mlv_23,//"请输入目标NodeID",
  mlv_24, //质押转移交易已提交
  mlv_25,//赎回 apply withdraw
  mlv_26,//批量提现
  mlv_27,//"请输入转移金额",
  mlv_28,//算力
  mlv_28_1,//算力升序
  mlv_28_2,//算力降序
  mlv_29,//收益
  mlv_29_1,//收益升序
  mlv_29_2,//收益降序
  mlv_30,//ID
  mlv_30_1,//ID升序
  mlv_30_2,//ID降序
  mlv_31,//质押
  mlv_32,//复制NodeID
  mlv_33,
  mlv_34,//目标NodeID数量与选中的不一致
  mlv_35,//批量转移质押


  ///AddOtherOwnerPledgeView
  aoopv_1,//新增Owner
  aoopv_2,//流量质押数量
  aoopv_3,//增加流量质押
  aoopv_4,//请输入OwnerID

  ///AddOtherMinerPledgeView
  aompv_1,//新增Miner
  aompv_2,//节点质押数量
  aompv_3,//增加节点质押
  aompv_4,//请输入NodeID

  //RemoteAuthView
  rav_1,//远程授权
  rav_2,//待授权数据
  rav_3,//原文
  rav_4,//接口
  rav_5,//确认授权
  rav_6,//授权成功
  rav_7,//授权失败


}
