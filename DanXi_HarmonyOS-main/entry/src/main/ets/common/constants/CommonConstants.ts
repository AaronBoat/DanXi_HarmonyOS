export class CommonConstants {
  // 基础 URL
  static readonly BASE_URL: string = 'https://dantan.fduhole.com/api';  // 旦挞后端API地址
  static readonly UIS_BASE_URL: string = 'https://uis.fudan.edu.cn';  // UIS系统地址
  static readonly UIS_LOGIN_URL: string = 'https://uis.fudan.edu.cn/authserver/login';  // UIS登录地址

  // 页面路由
  static readonly DEFAULT_PAGE: string = 'pages/Index';  // 默认页面路由

  // 存储键名
  static readonly STORAGE_KEY_USER_INFO: string = 'userInfo';  // 用户信息存储键
  static readonly STORAGE_KEY_TOKEN: string = 'token';  // token存储键
  static readonly STORAGE_KEY_UIS_COOKIES: string = 'uisCookies';  // UIS cookies存储键

  // HTTP 请求超时时间（毫秒）
  static readonly HTTP_TIMEOUT: number = 10000;

  // HTTP 响应码
  static readonly HTTP_CODE_SUCCESS: number = 200;
  static readonly HTTP_CODE_UNAUTHORIZED: number = 401;
  static readonly HTTP_CODE_FORBIDDEN: number = 403;
  static readonly HTTP_CODE_NOT_FOUND: number = 404;
  static readonly HTTP_CODE_SERVER_ERROR: number = 500;
} 