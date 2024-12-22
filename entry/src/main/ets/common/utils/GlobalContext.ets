export class GlobalContext {
  private static instance: GlobalContext;
  stageMode: boolean = true;
  private constructor() {}
  private contextMap: Map<string, Object> = new Map();

  public static getContext(): GlobalContext {
    if (!GlobalContext.instance) {
      GlobalContext.instance = new GlobalContext();
    }
    return GlobalContext.instance;
  }

  // 确保 GlobalContext 实例有一个 stageMode 属性
  public getStageMode(): boolean {
    return this.stageMode;
  }

  public setObject(key: string, value: Object): void {
    this.contextMap.set(key, value);
  }

  public getObject(key: string): Object | undefined {
    return this.contextMap.get(key);
  }
}
