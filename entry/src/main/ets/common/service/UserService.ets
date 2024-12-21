import { HttpService } from './HttpService'

export interface UserProfile {
  id: number
  username: string
  realName: string
  email: string
  department: string
  grade: number
}

export class UserService {
  private static _instance: UserService | null = null
  private httpService: HttpService

  private constructor() {
    this.httpService = HttpService.getInstance()
  }

  public static getInstance(): UserService {
    if (!this._instance) {
      this._instance = new UserService()
    }
    return this._instance
  }

  public async getUserProfile(): Promise<UserProfile | null> {
    try {
      const result = await this.httpService.get('https://your-api.com/user/profile', {
        headers: { 'Authorization': `Bearer ${globalThis.token}` }
      })
      return result?.data || null
    } catch (error) {
      console.error('获取用户信息失败:', error)
      return null
    }
  }

  public async updateUserProfile(profile: Partial<UserProfile>): Promise<boolean> {
    try {
      const result = await this.httpService.post('https://your-api.com/user/update', {
        ...profile,
        token: globalThis.token
      })
      return result?.success || false
    } catch (error) {
      console.error('更新用户信息失败:', error)
      return false
    }
  }

  public async changePassword(oldPassword: string, newPassword: string): Promise<boolean> {
    try {
      const result = await this.httpService.post('https://your-api.com/user/change-password', {
        oldPassword,
        newPassword,
        token: globalThis.token
      })
      return result?.success || false
    } catch (error) {
      console.error('修改密码失败:', error)
      return false
    }
  }
}
