export class LoggerService {
  private static _instance: LoggerService | null = null
  private _logLevel: 'debug' | 'info' | 'warn' | 'error' = 'info'

  private constructor() {}

  public static getInstance(): LoggerService {
    if (!LoggerService._instance) {
      LoggerService._instance = new LoggerService()
    }
    return LoggerService._instance
  }

  public setLogLevel(level: 'debug' | 'info' | 'warn' | 'error'): void {
    this._logLevel = level
  }

  private _log(level: 'debug' | 'info' | 'warn' | 'error', ...args: Object[]): void {
    const levels = ['debug', 'info', 'warn', 'error']
    if (levels.indexOf(level) >= levels.indexOf(this._logLevel)) {
      const timestamp = new Date().toISOString()
      console[level](`[${timestamp}] [${level.toUpperCase()}]`, ...args)
    }
  }

  public debug(...args: Object[]): void {
    this._log('debug', ...args)
  }

  public info(...args: Object[]): void {
    this._log('info', ...args)
  }

  public warn(...args: Object[]): void {
    this._log('warn', ...args)
  }

  public error(...args: Object[]): void {
    this._log('error', ...args)
  }

  public logApiCall(method: string, url: string, data: Object): void {
    this.debug(`API Call: ${method} ${url}`, data)
  }

  public logApiResponse(url: string, response: Object): void {
    this.debug(`API Response: ${url}`, response)
  }
}
