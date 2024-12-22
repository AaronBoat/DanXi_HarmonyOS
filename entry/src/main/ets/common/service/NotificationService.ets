import promptAction from '@ohos.promptAction'
import router from '@ohos.router'

export class NotificationService {
  private static _instance: NotificationService | null = null

  private constructor() {}

  public static getInstance(): NotificationService {
    if (!NotificationService._instance) {
      NotificationService._instance = new NotificationService()
    }
    return NotificationService._instance
  }

  public showToast(message: string, duration: number = 2000): void {
    promptAction.showToast({
      message: message,
      duration: duration
    })
  }

  public showAlert(title: string, message: string): void {
    promptAction.showDialog({
      title: title,
      message: message,
      buttons: [
        {
          text: '确定',
          color: '#FF0000'
        }
      ]
    })
  }

  public navigateTo(url: string, params?: object): void {
    router.pushUrl({
      url: url,
      params: params
    })
  }

  public replaceUrl(url: string, params?: object): void {
    router.replaceUrl({
      url: url,
      params: params
    })
  }
}
