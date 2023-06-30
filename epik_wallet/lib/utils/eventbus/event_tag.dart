enum EventTag {
  // 未读消息更新
  UnreadUpdate,
  // 切换mainview的页面索引
  CHANGE_MAINVIEW_INDEX,

  // 主页面右侧抽屉菜单 打开或关闭
  MAIN_RIGHT_DRAWER,

  // 主页面右侧抽屉菜单 矿机ID 打开或关闭
  MAIN_RIGHT_DRAWER_MINER,

  // 当前的矿机ID 发生变更
  MINER_CURRENT_CHENGED,

  // 本地账号列表变更
  LOCAL_ACCOUNT_LIST_CHANGE,
  // 当前账号变更
  LOCAL_CURRENT_ACCOUNT_CHANGE,

  //预挖活动页面需要刷新
  REFRESH_MININGVIEW,

  // 二维码扫描结果
  SCAN_QRCODE_RESULT,

  BALANCE_UPDATE,

  BALANCE_UPDATE_SINGLE,

  // aibot充值的点数 更新数据
  AI_BOT_POINT_UPDATE,

  UNISWAP_ADD,
  UNISWAP_REMOVE,

  // 已刷新eth合约gas
  UPLOAD_SUGGESTGAS,
  // 已刷新uniswap信息
  UPLOAD_UNISWAPINFO,
  // 服务配置已更新
  UPDATE_SERVER_CONFIG,

  // bounty奖励的公示列表重新编辑过
  BOUNTY_EDITED_USER_LIST,

  //绑定社交账号
  BIND_SOCIAL_ACCCOUNT,

  COINBASEINFO_UPDATE,

  UPLOAD_EPIK_GAS_TRANSFER,
}
