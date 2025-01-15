import HttpService from './HttpService';
import { StorageService } from './StorageService';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { ResponseResult } from '../model/ResponseResult'

// 定义登录响应结果的接口
export interface LoginResponse {
  success: boolean;
  token?: string;
  userInfo?: Record<string, string>;
  message?: string;
}

export class AuthService {
  private static instance: AuthService;
  private httpService: HttpService;
  private storageService: StorageService | null = null;

  private constructor() {
    this.httpService = HttpService.getInstance();
    StorageService.getInstance().then(service => {
      this.storageService = service;
    });
  }

  public static getInstance(): AuthService {
    if (!AuthService.instance) {
      AuthService.instance = new AuthService();
    }
    return AuthService.instance;
  }

  public async login(username: string, password: string): Promise<boolean> {
    try {
      let data: Record<string, Object> = {
        "username": username,
        "password": password
      }
      const response: ResponseResult<string> = await this.httpService.post('https://uis.fudan.edu.cn/authserver/login', data);

      const result: LoginResponse = JSON.parse(response.data ?? "");
      if (result.success) {
        await this.storageService?.setString('token', result.token ?? "");
        await this.storageService?.setString('username', username);
        await this.storageService?.setObject('userInfo', result.userInfo ?? Object());
        
        // 显示登录成功提示
        promptAction.showToast({
          message: '登录成功',
          duration: 2000
        });

        // 跳转到主页
        router.replaceUrl({ url: 'pages/Index' });
        return true;
      } else {
        // 显示登录失败提示
        promptAction.showToast({
          message: result.message || '登录失败，请检查用户名和密码',
          duration: 2000
        });
        return false;
      }
    } catch (error) {
      console.error('Login failed:', error);
      
      // 显示网络错误提示
      promptAction.showToast({
        message: '网络错误，请检查网络连接',
        duration: 2000
      });
      
      return false;
    }
  }

  public async isLoggedIn(): Promise<boolean> {
    const token = await this.storageService?.getString('token');
    return !!token;
  }

  public async logout(): Promise<void> {
    try {
      // 可选：调用服务器注销接口
      let token: string = await this.storageService?.getString('token') ?? "";
      let data: Record<string, Object> = {
        "token": token
      }
      await this.httpService.post<void>('https://uis.fudan.edu.cn/authserver/logout', data); // 显式指定泛型参数
    } catch (error) {
      console.error('Logout server call failed:', error);
    }

    // 清除本地存储
    await this.storageService?.remove('token');
    await this.storageService?.remove('username');
    await this.storageService?.remove('userInfo');

    // 显示注销成功提示
    promptAction.showToast({
      message: '已成功注销',
      duration: 2000
    });

    // 跳转到登录页
    router.replaceUrl({ url: 'pages/LoginPage' });
  }

  public async getCurrentUsername(): Promise<string> {
    return await this.storageService?.getString('username', '') || '';
  }

  public async getUserInfo(): Promise<Record<string, string>> {
    let emptyInfo: Record<string, string> = {};
    return await this.storageService?.getObject<Record<string, string>>('userInfo', emptyInfo) ?? emptyInfo;
  }
}
