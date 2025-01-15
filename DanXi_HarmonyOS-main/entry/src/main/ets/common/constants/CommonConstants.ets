export class CommonConstants {
  // API URLs - 开发环境地址
  static readonly API_BASE_URL: string = 'http://localhost:3000';  // 或者你的本地/测试服务器地址
  static readonly API_LOGIN_ENDPOINT: string = '/auth/login';
  static readonly API_REGISTER_ENDPOINT: string = '/auth/register';
  
  // UIS URLs
  static readonly UIS_BASE_URL: string = 'https://uis.fudan.edu.cn';
  static readonly UIS_LOGIN_URL: string = 'https://uis.fudan.edu.cn/authserver/login';
  static readonly UIS_USER_INFO_URL: string = 'https://uis.fudan.edu.cn/userinfo';

  // Storage Keys
  static readonly STORAGE_KEY_USER_INFO: string = 'userInfo';
  static readonly STORAGE_KEY_TOKEN: string = 'token';
  static readonly STORAGE_KEY_UIS_COOKIES: string = 'uisCookies';

  // HTTP Settings
  static readonly HTTP_TIMEOUT: number = 10000;
  static readonly HTTP_CODE_SUCCESS: number = 200;

  // Routes
  static readonly DEFAULT_PAGE: string = 'pages/Index';
}
