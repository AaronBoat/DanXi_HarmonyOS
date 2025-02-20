export class CommonConstants {
  /**
   * 底部标签栏索引
   */
  static readonly HOME_TAB_INDEX = 0;
  static readonly COURSE_TAB_INDEX = 1;
  static readonly PROFILE_TAB_INDEX = 2;

  /**
   * 路由路径
   */
  static readonly HOME_PAGE = 'pages/HomePage';
  static readonly COURSE_PAGE = 'pages/CoursePage';
  static readonly PROFILE_PAGE = 'pages/ProfilePage';
  static readonly DEFAULT_PAGE = CommonConstants.COURSE_PAGE;

  /**
   * 资源路径
   */
  static readonly APP_ICON = 'app.media.app_icon';

  /**
   * 网址URL
   */
  static readonly _LOGIN_URL = "https://uis.fudan.edu.cn/authserver/login?service=http%3A%2F%2Fjwc.fudan.edu.cn%2Feb%2Fb7%2Fc9397a388023%2Fpage.psp";

  /**
   * 颜色
   */
  static readonly SELECTED_BUTTON_COLOR = '#1698CE';
  static readonly UNSELECTED_BUTTON_COLOR = '#F0F0F0';

  static get CAPTCHA_CODE_NEEDED(): string {
    return "请输入验证码";
  }

  static get CREDENTIALS_INVALID(): string {
    return "密码有误";
  }

  static get WEAK_PASSWORD(): string {
    return "弱密码提示";
  }

  static get UNDER_MAINTENANCE(): string {
    return "网络维护中 | Under Maintenance";
  }
}
