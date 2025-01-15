import http from '@ohos.net.http';
import { CommonConstants } from '../constants/CommonConstants';
import { UserInfo, UserGroup } from '../../models/UserInfo';
import { StorageService } from './StorageService';

export class LoginService {
  private static instance: LoginService;
  private storageService: StorageService | null = null;

  private constructor() {
    // 私有构造函数
  }

  static getInstance(): LoginService {
    if (!LoginService.instance) {
      LoginService.instance = new LoginService();
    }
    return LoginService.instance;
  }

  async init(): Promise<void> {
    this.storageService = await StorageService.getInstance();
  }

  async dantanLogin(username: string, password: string): Promise<void> {
    try {
      const loginUrl = CommonConstants.BASE_URL + '/auth/login';
      const httpRequest = http.createHttp();
      
      const response = await httpRequest.request(loginUrl, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify({
          username: username,
          password: password
        }),
        connectTimeout: CommonConstants.HTTP_TIMEOUT,
        readTimeout: CommonConstants.HTTP_TIMEOUT
      });

      const responseData = JSON.parse(response.result as string);
      
      if (response.responseCode === CommonConstants.HTTP_CODE_SUCCESS) {
        let userInfo: UserInfo = {
          id: username,
          password: password,
          name: responseData.name || username,
          userGroup: UserGroup.VISITOR
        };
        
        await this.storageService?.setObject(CommonConstants.STORAGE_KEY_USER_INFO, userInfo);
        await this.storageService?.setString(CommonConstants.STORAGE_KEY_TOKEN, responseData.token);
      } else {
        throw new Error(responseData.message || '登录失败');
      }
    } catch (error) {
      throw new Error('登录失败：' + (error.message || '网络错误'));
    }
  }

  async uisLogin(username: string, password: string): Promise<void> {
    try {
      const loginUrl = CommonConstants.UIS_LOGIN_URL;
      const httpRequest = http.createHttp();
      
      const loginPageResponse = await httpRequest.request(loginUrl, {
        method: http.RequestMethod.GET,
        header: {
          'User-Agent': 'Mozilla/5.0'
        }
      });

      const loginPageContent = loginPageResponse.result as string;
      const formData = this.parseLoginForm(loginPageContent);
      formData['username'] = username;
      formData['password'] = password;

      const loginResponse = await httpRequest.request(loginUrl, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'Mozilla/5.0'
        },
        extraData: this.encodeFormData(formData)
      });

      const responseText = loginResponse.result as string;
      await this.checkUisLoginResult(responseText, username, password, loginResponse.cookies);

    } catch (error) {
      throw error;
    }
  }

  private async checkUisLoginResult(responseText: string, username: string, password: string, cookies: string[]): Promise<void> {
    if (responseText.includes('密码有误')) {
      throw new Error('密码错误');
    }
    if (responseText.includes('请输入验证码')) {
      throw new Error('需要输入验证码');
    }
    if (responseText.includes('网络维护中')) {
      throw new Error('系统维护中');
    }
    if (!responseText.includes('登录成功') && !responseText.includes('index.jsp')) {
      throw new Error('登录失败');
    }

    // 登录成功，保存用户信息
    let userInfo: UserInfo = {
      id: username,
      password: password,
      name: await this.fetchStudentName(username),
      userGroup: UserGroup.FUDAN_UNDERGRADUATE_STUDENT
    };

    await this.storageService?.setObject(CommonConstants.STORAGE_KEY_USER_INFO, userInfo);
    if (cookies) {
      await this.storageService?.setString(CommonConstants.STORAGE_KEY_UIS_COOKIES, cookies.join('; '));
    }
  }

  private parseLoginForm(html: string): Record<string, string> {
    const formData: Record<string, string> = {};
    const inputMatches = html.match(/<input[^>]+name="([^"]+)"[^>]+value="([^"]*)"[^>]*>/g);

    if (inputMatches) {
      for (const match of inputMatches) {
        const nameMatch = match.match(/name="([^"]+)"/);
        const valueMatch = match.match(/value="([^"]*)"/);

        if (nameMatch && valueMatch) {
          formData[nameMatch[1]] = valueMatch[1];
        }
      }
    }

    return formData;
  }

  private encodeFormData(data: Record<string, string>): string {
    return Object.keys(data).map((key) => {
      return `${encodeURIComponent(key)}=${encodeURIComponent(data[key])}`;
    }).join('&');
  }

  private async fetchStudentName(username: string): Promise<string> {
    // TODO: 实现从UIS获取学生姓名的逻辑
    return username;
  }
} 