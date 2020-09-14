enum EventTag {
  // 未读消息更新
  UnreadUpdate,
  // 切换mainview的页面索引
  CHANGE_MAINVIEW_INDEX,

  // 主页面右侧抽屉菜单 打开或关闭
  MAIN_RIGHT_DRAWER,


  // 本地账号列表变更
  LOCAL_ACCOUNT_LIST_CHANGE,
  // 当前账号变更
  LOCAL_CURRENT_ACCOUNT_CHANGE,

  //预挖活动页面需要刷新
  REFRESH_MININGVIEW,

  // 二维码扫描结果
  SCAN_QRCODE_RESULT,

  BALANCE_UPDATE,

  UNISWAP_ADD,
}
