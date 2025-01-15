import http from '@ohos.net.http';
import { CommonConstants } from '../constants/CommonConstants';
import { UserInfo, UserGroup } from '../../models/UserInfo';
import { StorageService } from './StorageService';

class KeyValuePair {
  key: string;
  value: string;

  constructor(key: string, value: string) {
    this.key = key;
    this.value = value;
  }
}

class ObjectLiteral {
  private data: Record<string, any> = {};

  constructor() {}

  static create(): ObjectLiteral {
    return new ObjectLiteral();
  }

  set(key: string, value: any): ObjectLiteral {
    this.data[key] = value;
    return this;
  }

  get(key: string): any {
    return this.data[key];
  }

  toJSON(): string {
    return JSON.stringify(this.data);
  }

  static fromJSON(json: string): ObjectLiteral {
    const obj = new ObjectLiteral();
    obj.data = JSON.parse(json);
    return obj;
  }
}

class SimpleObject {
  private pairs: Array<KeyValuePair> = [];

  constructor() {}

  static create(): SimpleObject {
    return new SimpleObject();
  }

  set(key: string, value: string): SimpleObject {
    const existingPair = this.pairs.find(p => p.key === key);
    if (existingPair) {
      existingPair.value = value;
    } else {
      this.pairs.push(new KeyValuePair(key, value));
    }
    return this;
  }

  get(key: string): string | undefined {
    const pair = this.pairs.find(p => p.key === key);
    return pair ? pair.value : undefined;
  }

  toObject(): ObjectLiteral {
    const obj = ObjectLiteral.create();
    this.pairs.forEach(pair => {
      obj.set(pair.key, pair.value);
    });
    return obj;
  }
}

class StringMap {
  private data: SimpleObject = SimpleObject.create();

  set(key: string, value: string): void {
    this.data.set(key, value);
  }

  get(key: string): string | undefined {
    return this.data.get(key);
  }

  toObject(): object {
    return this.data.toObject();
  }
}

class HttpHeader {
  private headers: StringMap = new StringMap();

  constructor() {
    this.headers = new StringMap();
  }

  static create(): HttpHeader {
    return new HttpHeader();
  }

  add(key: string, value: string): HttpHeader {
    this.headers.set(key, value);
    return this;
  }

  toObject(): object {
    return this.headers.toObject();
  }
}

class LoginResponse {
  name?: string;
  token?: string;
  message?: string;

  constructor(name?: string, token?: string, message?: string) {
    this.name = name;
    this.token = token;
    this.message = message;
  }

  static fromObject(obj: object): LoginResponse {
    const response = new LoginResponse();
    Object.assign(response, obj);
    return response;
  }
}

class DeviceInfo {
  platform: string;
  version: string;
  deviceModel: string;

  constructor(platform: string, version: string, deviceModel: string) {
    this.platform = platform;
    this.version = version;
    this.deviceModel = deviceModel;
  }
}

class LoginRequest {
  username: string;
  password: string;
  deviceInfo: DeviceInfo;

  constructor(username: string, password: string, deviceInfo: DeviceInfo) {
    this.username = username;
    this.password = password;
    this.deviceInfo = deviceInfo;
  }

  toJSON(): string {
    return JSON.stringify({
      username: this.username,
      password: this.password,
      deviceInfo: {
        platform: this.deviceInfo.platform,
        version: this.deviceInfo.version,
        deviceModel: this.deviceInfo.deviceModel
      }
    });
  }
}

class HttpRequestOptions {
  method: http.RequestMethod;
  header: object;
  extraData?: string;
  connectTimeout?: number;
  readTimeout?: number;

  constructor(method: http.RequestMethod, header: HttpHeader, extraData?: string, 
    connectTimeout?: number, readTimeout?: number) {
    this.method = method;
    this.header = header.toObject();
    this.extraData = extraData;
    this.connectTimeout = connectTimeout;
    this.readTimeout = readTimeout;
  }
}

class HttpRequest {
  private request: http.HttpRequest;

  constructor() {
    this.request = http.createHttp();
  }

  async request(url: string, options: HttpRequestOptions): Promise<http.HttpResponse> {
    return await this.request.request(url, options);
  }

  destroy(): void {
    this.request.destroy();
  }
}

class FormData {
  private data: StringMap = new StringMap();

  set(key: string, value: string): void {
    this.data.set(key, value);
  }

  get(key: string): string | undefined {
    return this.data.get(key);
  }

  entries(): Array<[string, string]> {
    const entries: Array<[string, string]> = [];
    const obj = this.data.toObject();
    Object.keys(obj).forEach(key => {
      entries.push([key, obj[key]]);
    });
    return entries;
  }
}

class UISUserInfo {
  name?: string;
  studentId?: string;
  department?: string;
  grade?: string;
  major?: string;
  class?: string;
  email?: string;
  phone?: string;

  constructor(data: SimpleObject = SimpleObject.create()) {
    Object.assign(this, data);
  }
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
    let httpRequest: HttpRequest | null = null;
    try {
      httpRequest = new HttpRequest();
      const loginUrl = `${CommonConstants.API_BASE_URL}${CommonConstants.API_LOGIN_ENDPOINT}`;
      console.info(`正在尝试登录，URL: ${loginUrl}`);
      
      const deviceInfo = new DeviceInfo('HarmonyOS', '1.0.0', 'Unknown');
      const loginData = new LoginRequest(username, password, deviceInfo);

      const headers = HttpHeader.create()
        .add('Content-Type', 'application/json')
        .add('Accept', 'application/json');

      const requestOptions = new HttpRequestOptions(
        http.RequestMethod.POST,
        headers,
        loginData.toJSON(),
        CommonConstants.HTTP_TIMEOUT,
        CommonConstants.HTTP_TIMEOUT
      );

      const response = await httpRequest.request(loginUrl, requestOptions);
      console.info(`登录响应状态码: ${response.responseCode}`);

      const responseObj = ObjectLiteral.fromJSON(response.result as string);
      const responseData = LoginResponse.fromObject(responseObj);
      console.info('登录响应内容:', responseObj.toJSON());
      
      if (response.responseCode === CommonConstants.HTTP_CODE_SUCCESS && responseData.token) {
        const userInfo = new UserInfo();
        userInfo.id = username;
        userInfo.password = password;
        userInfo.name = responseData.name || username;
        userInfo.userGroup = UserGroup.VISITOR;
        
        if (this.storageService) {
          await this.storageService.setObject(CommonConstants.STORAGE_KEY_USER_INFO, userInfo);
          await this.storageService.setString(CommonConstants.STORAGE_KEY_TOKEN, responseData.token);
        } else {
          throw new Error('存储服务未初始化');
        }
      } else {
        throw new Error(responseData.message || '用户名或密码错误');
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
      if (httpRequest) {
        httpRequest.destroy();
      }
    }
  }

  async uisLogin(username: string, password: string): Promise<void> {
    let httpRequest: HttpRequest | null = null;
    try {
      httpRequest = new HttpRequest();
      const loginUrl = CommonConstants.UIS_LOGIN_URL;
      
      const headers = HttpHeader.create()
        .add('User-Agent', 'Mozilla/5.0');

      const getRequestOptions = new HttpRequestOptions(
        http.RequestMethod.GET,
        headers
      );

      const loginPageResponse = await httpRequest.request(loginUrl, getRequestOptions);
      const loginPageContent = loginPageResponse.result as string;
      const formData = this.parseLoginForm(loginPageContent);
      formData.set('username', username);
      formData.set('password', password);

      const postHeaders = HttpHeader.create()
        .add('Content-Type', 'application/x-www-form-urlencoded')
        .add('User-Agent', 'Mozilla/5.0');

      const postRequestOptions = new HttpRequestOptions(
        http.RequestMethod.POST,
        postHeaders,
        this.encodeFormData(formData)
      );

      const loginResponse = await httpRequest.request(loginUrl, postRequestOptions);
      const responseText = loginResponse.result as string;
      
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

      const userInfo = new UserInfo();
      userInfo.id = username;
      userInfo.password = password;
      userInfo.name = await this.fetchStudentName();
      userInfo.userGroup = UserGroup.FUDAN_UNDERGRADUATE_STUDENT;

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
    } finally {
      if (httpRequest) {
        httpRequest.destroy();
      }
    }
  }

  private parseLoginForm(html: string): FormData {
    const formData = new FormData();
    const inputMatches = html.match(/<input[^>]+name="([^"]+)"[^>]+value="([^"]*)"[^>]*>/g);

    if (inputMatches) {
      for (const match of inputMatches) {
        const nameMatch = match.match(/name="([^"]+)"/);
        const valueMatch = match.match(/value="([^"]*)"/);

        if (nameMatch && valueMatch) {
          formData.set(nameMatch[1], valueMatch[1]);
        }
      }
    }

    return formData;
  }

  private encodeFormData(formData: FormData): string {
    return formData.entries().map(([key, value]) => {
      return `${encodeURIComponent(key)}=${encodeURIComponent(value)}`;
    }).join('&');
  }

  private async fetchStudentName(): Promise<string> {
    let httpRequest: HttpRequest | null = null;
    try {
      httpRequest = new HttpRequest();
      const userInfoUrl = CommonConstants.UIS_USER_INFO_URL;
      
      const headers = HttpHeader.create()
        .add('User-Agent', 'Mozilla/5.0');

      const requestOptions = new HttpRequestOptions(
        http.RequestMethod.GET,
        headers
      );

      const response = await httpRequest.request(userInfoUrl, requestOptions);

      if (response.responseCode === CommonConstants.HTTP_CODE_SUCCESS) {
        const responseObj = SimpleObject.create();
        Object.assign(responseObj, JSON.parse(response.result as string));
        const userInfoData = new UISUserInfo(responseObj);
        return userInfoData.name || '未知用户';
      }
      
      return '未知用户';
    } catch (error) {
      console.error('获取用户姓名失败：', error instanceof Error ? error.message : String(error));
      return '未知用户';
    } finally {
      if (httpRequest) {
        httpRequest.destroy();
      }
    }
  }
} 