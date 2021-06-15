import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/main.dart';

extension RSID_ex on RSID {
  String get text {
    return ResString.get(appContext, this);
  }
}

enum RSID {
  //base
  doubleclickquit,
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
  content_empty,
  no_more,
  net_error,
  takephoto,
  gallery,
  unknown,

  //----------------------------------------dialog.*
  //BottomDialog
  dlg_bd_1,
  dlg_bd_2,
  dlg_bd_3,
  dlg_bd_4,

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

  //----------------------------------------views.qrcode.*
  //QrcodeScanView 扫描二维码
  qsv_1,
  qsv_2,

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
  //---add
  minerview_15, //注意：\n- 知识矿工需要启动实体矿机才能参与挖矿\n- 知识矿工需要完成1000EPK的矿工基础抵押才能获得出块资格\n- 知识矿工需要从网络里读取新文件，存储新文件才能增加算力，增大出块概率 \n- 1EPK=10Mb的每日访问流量，每日已用访问流量将会返还\n- 您可以在任何时候赎回抵押的EPK
  minerview_16, // EPK 可用
  minerview_17, //访问流量抵押
  minerview_18, //交易已提交
  minerview_19, //查看交易
  minerview_20, //添加抵押交易已提交
  //---withdraw
  minerview_21, //注意：\n- 仅能赎回自己抵押的EPK\n- 如果你当前已经消耗了一部分访问流量，则无法赎回全部的访问流量抵押，请尝试减少赎回的数量\n- 矿工基础抵押赎回中的EPK将会立刻到账\n- 访问流量抵押的EPK需要在解锁操作3天后才能赎回\n
  minerview_22, // EPK 赎回
  minerview_23, // EPK 可解锁
  minerview_24, // 解锁
  minerview_25, //访问流量抵押
  minerview_26, //赎回抵押交易已提交
  minerview_27, //解锁抵押交易已提交
  //---MinerMenu
  minermenu_1, //选择MinerID
  minermenu_2, //删除MinerID
  minermenu_3, //删除
  minermenu_4, //添加MinerID
  minermenu_5, //请输入MinerID

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
  expertview_15,
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
  applyexpertview_16, //姓名(公开)
  applyexpertview_17, //手机号(非公开)
  applyexpertview_18, //邮箱(非公开)
  applyexpertview_19, //想申请的领域(公开)
  applyexpertview_20, //请从教育背景，工作经历，影响力等方面介绍自己
  applyexpertview_21, //个人介绍(公开)
  applyexpertview_22, //知识图谱数据默认遵循无任何限制的开源协议，如对开源协议有任何特殊要求，请填写如下（选填）
  applyexpertview_23, //开源协议(公开)
  applyexpertview_24, //交易确认中
  applyexpertview_25, //领域专家申请已提交，请等待审核。
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

}
