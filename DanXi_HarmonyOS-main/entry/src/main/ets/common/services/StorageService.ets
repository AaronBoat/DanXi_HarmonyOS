import dataPreferences from '@ohos.data.preferences';

@Observed
export class StorageService {
  private static instance: StorageService;
  private preferences: dataPreferences.Preferences | null = null;

  private constructor() {}

  static getInstance(): StorageService {
    if (!StorageService.instance) {
      StorageService.instance = new StorageService();
    }
    return StorageService.instance;
  }

  async init(): Promise<void> {
    try {
      const context = getContext(this);
      this.preferences = await dataPreferences.getPreferences(context, 'DanTan_Storage');
    } catch (error) {
      console.error('初始化存储服务失败：', error instanceof Error ? error.message : String(error));
    }
  }

  async setString(key: string, value: string): Promise<void> {
    try {
      await this.preferences?.put(key, value);
      await this.preferences?.flush();
    } catch (error) {
      console.error(`存储字符串失败 [${key}]:`, error instanceof Error ? error.message : String(error));
    }
  }

  async setObject(key: string, value: object): Promise<void> {
    try {
      await this.setString(key, JSON.stringify(value));
    } catch (error) {
      console.error(`存储对象失败 [${key}]:`, error instanceof Error ? error.message : String(error));
    }
  }
} 