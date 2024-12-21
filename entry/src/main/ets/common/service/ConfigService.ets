export class ConfigService {
  private static _instance: ConfigService | null = null
  private _config: Record<string, any> = {
    // 应用基础配置
    appName: 'DanXi课程管理',
    version: '1.0.0',

    // 网络配置
    baseUrl: 'https://your-api.com',
    timeout: 10000,

    // 功能开关
    features: {
      courseEnroll: true,
      userProfile: true,
      notifications: true
    },

    // 主题配置
    theme: {
      primaryColor: '#3F51B5',
      secondaryColor: '#FF4081',
      darkMode: false
    }
  }

  private constructor() {}

  public static getInstance(): ConfigService {
    if (!this._instance) {
      this._instance = new ConfigService()
    }
    return this._instance

  }

  public get(key: string, defaultValue?: any): any {
    const keys = key.split('.')
    let value = this._config

    for (const k of keys) {
      if (value && typeof value === 'object' && k in value) {
        value = value[k]
      } else {
        return defaultValue
      }
    }

    return value
  }

  public set(key: string, value: any): void {
    const keys = key.split('.')
    let config = this._config

    for (let i = 0; i < keys.length - 1; i++) {
      const k = keys[i]
      if (!(k in config) || typeof config[k] !== 'object') {
        config[k] = {}
      }
      config = config[k]
    }

    config[keys[keys.length - 1]] = value
  }

  public reset(): void {
    this._config = {
      appName: 'DanXi课程管理',
      version: '1.0.0',
      baseUrl: 'https://your-api.com',
      timeout: 10000,
      features: {
        courseEnroll: true,
        userProfile: true,
        notifications: true
      },
      theme: {
        primaryColor: '#3F51B5',
        secondaryColor: '#FF4081',
        darkMode: false
      }
    }
  }
}
