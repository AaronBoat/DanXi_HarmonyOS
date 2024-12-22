export class ConfigService {
  private static _instance: ConfigService | null = null
  private _config: Record<string, Object> = {
    // 应用基础配置
    "appName": 'DanXi课程管理',
    "version": '1.0.0',

    // 网络配置
    "baseUrl": 'https://your-api.com',
    "timeout": 10000,

    // 功能开关
    "features.courseEnroll": true,
    "features.userProfile": true,
    "features.notifications": true,

    // 主题配置
    "theme.primaryColor": '#3F51B5',
    "theme.secondaryColor": '#FF4081',
    "theme.darkMode": false
  }

  private constructor() {}

  public static getInstance(): ConfigService {
    if (!ConfigService._instance) {
      ConfigService._instance = new ConfigService()
    }
    return ConfigService._instance

  }

  public get(key: string, defaultValue: Object = false): Object {
    if (Object.keys(this._config).includes(key)) {
      return  Reflect.get(this._config, key);
    } else {
      return defaultValue
    }
  }

  public set(key: string, value: Object): void {
    this._config[key] = value;
  }

  public reset(): void {
    this._config = {
      // 应用基础配置
      "appName": 'DanXi课程管理',
      "version": '1.0.0',

      // 网络配置
      "baseUrl": 'https://your-api.com',
      "timeout": 10000,

      // 功能开关
      "features.courseEnroll": true,
      "features.userProfile": true,
      "features.notifications": true,

      // 主题配置
      "theme.primaryColor": '#3F51B5',
      "theme.secondaryColor": '#FF4081',
      "theme.darkMode": false
    }
  }
}
