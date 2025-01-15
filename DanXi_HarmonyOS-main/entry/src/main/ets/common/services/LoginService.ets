import http from '@ohos.net.http';
import { CommonConstants } from '../constants/CommonConstants';
import { UserInfo, UserGroup } from '../../models/UserInfo';
import { StorageService } from './StorageService';

interface LoginResponse {
  name?: string;
  token?: string;
  message?: string;
}

// 修改用户信息接口定义
interface UISUserInfo {
  name?: string;
  studentId?: string;
  department?: string;
  grade?: string;
  major?: string;
  class?: string;
  email?: string;
  phone?: string;
}

@Observed
export class LoginService {
  private static instance: LoginService;
  private storageService: StorageService | null = null;

  private constructor() {}

  static getInstance(): LoginService {
    if (!LoginService.instance) {
      LoginService.instance = new LoginService();
    }
    return LoginService.instance;
  }

  async init(): Promise<void> {
    this.storageService = StorageService.getInstance();
    await this.storageService.init();
  }

  async dantanLogin(username: string, password: string): Promise<void> {
    try {
      const loginUrl = `${CommonConstants.API_BASE_URL}${CommonConstants.API_LOGIN_ENDPOINT}`;
      console.info(`正在尝试登录，URL: ${loginUrl}`);
      
      const httpRequest = http.createHttp();
      
      const response = await httpRequest.request(loginUrl, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        extraData: JSON.stringify({
          username: username,
          password: password,
          deviceInfo: {
            platform: 'HarmonyOS',
            version: '1.0.0',
            deviceModel: 'Unknown'
          }
        }),
        connectTimeout: CommonConstants.HTTP_TIMEOUT,
        readTimeout: CommonConstants.HTTP_TIMEOUT
      });

      console.info(`登录响应状态码: ${response.responseCode}`);

      try {
        const responseData = JSON.parse(response.result as string) as LoginResponse;
        console.info('登录响应内容:', JSON.stringify(responseData));
        
        if (response.responseCode === CommonConstants.HTTP_CODE_SUCCESS && responseData.token) {
          const userInfo: UserInfo = {
            id: username,
            password: password,
            name: responseData.name || username,
            userGroup: UserGroup.VISITOR
          };
          
          if (this.storageService) {
            await this.storageService.setObject(CommonConstants.STORAGE_KEY_USER_INFO, userInfo);
            await this.storageService.setString(CommonConstants.STORAGE_KEY_TOKEN, responseData.token);
          } else {
            throw new Error('存储服务未初始化');
          }
        } else {
          throw new Error(responseData.message || '用户名或密码错误');
        }
      } catch (parseError) {
        console.error('解析响应数据失败:', response.result);
        throw new Error('服务器响应格式错误');
      }
    } catch (error) {
      console.error('登录过程出错:', error);
      if (error instanceof Error) {
        if (error.message.includes('Failed to request url')) {
          throw new Error('无法连接到服务器，请检查网络连接');
        } else if (error.message.includes('timeout')) {
          throw new Error('请求超时，请检查网络连接');
        } else {
          throw new Error(error.message);
        }
      } else {
        throw new Error('网络错误');
      }
    } finally {
      httpRequest.destroy();
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
      
      // 检查登录结果
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
      const userInfo: UserInfo = {
        id: username,
        password: password,
        name: await this.fetchStudentName(),
        userGroup: UserGroup.FUDAN_UNDERGRADUATE_STUDENT
      };

      if (this.storageService) {
        await this.storageService.setObject(CommonConstants.STORAGE_KEY_USER_INFO, userInfo);
        if (loginResponse.cookies && Array.isArray(loginResponse.cookies)) {
          await this.storageService.setString(CommonConstants.STORAGE_KEY_UIS_COOKIES, loginResponse.cookies.join('; '));
        }
      } else {
        throw new Error('存储服务未初始化');
      }
    } catch (error) {
      throw new Error(error instanceof Error ? error.message : '登录失败');
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

  private async fetchStudentName(): Promise<string> {
    try {
      const userInfoUrl = CommonConstants.UIS_USER_INFO_URL;
      const httpRequest = http.createHttp();
      
      const response = await httpRequest.request(userInfoUrl, {
        method: http.RequestMethod.GET,
        header: {
          'User-Agent': 'Mozilla/5.0'
        }
      });

      if (response.responseCode === CommonConstants.HTTP_CODE_SUCCESS) {
        const userInfoData = JSON.parse(response.result as string) as UISUserInfo;  // 添加类型断言
        return userInfoData.name || '未知用户';
      }
      
      return '未知用户';
    } catch (error) {
      console.error('获取用户姓名失败：', error instanceof Error ? error.message : String(error));
      return '未知用户';
    }
  }
} 