import http from '@ohos.net.http'
import { ResponseResult } from '../model/ResponseResult'

export enum HttpMethod {
  GET = 'GET',
  POST = 'POST',
  PUT = 'PUT',
  DELETE = 'DELETE'
}

export interface HttpRequestOptions {
  headers?: Record<string, string>
  timeout?: number
  needToken?: boolean
}

@Observed
export default class HttpService {
  private static _instance: HttpService | null = null
  private baseUrl: string = 'https://danxi.fduhole.com/api' // DanXi的API地址
  private defaultTimeout: number = 10000
  private token: string = ''

  private constructor() {}

  public static getInstance(): HttpService {
    if (!HttpService._instance) {
      HttpService._instance = new HttpService()
    }
    return HttpService._instance
  }

  public setToken(token: string): void {
    this.token = token
  }

  public async request<T>(
    method: HttpMethod, 
    url: string, 
    data?: Record<string, any>, 
    options?: HttpRequestOptions
  ): Promise<ResponseResult<T>> {
    const fullUrl = `${this.baseUrl}${url}`
    const headers = options?.headers || {}
    if (options?.needToken && this.token) {
      headers['Authorization'] = `Bearer ${this.token}`
    }

    const requestOptions: http.RequestOptions = {
      method,
      url: fullUrl,
      headers,
      connectTimeout: options?.timeout || this.defaultTimeout,
      readTimeout: options?.timeout || this.defaultTimeout,
      extraData: data ? JSON.stringify(data) : undefined
    }

    try {
      const response = await http.request(requestOptions)
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as ResponseResult<T>
      } else {
        throw new Error(`HTTP Error: ${response.responseCode}`)
      }
    } catch (error) {
      console.error('HTTP request failed:', error)
      throw error
    }
  }

  public async get<T>(url: string, options?: HttpRequestOptions): Promise<ResponseResult<T>> {
    return this.request<T>(HttpMethod.GET, url, undefined, options)
  }

  public async post<T>(url: string, data: Record<string, any>, options?: HttpRequestOptions): Promise<ResponseResult<T>> {
    return this.request<T>(HttpMethod.POST, url, data, options)
  }

  public async put<T>(url: string, data: Record<string, unknown>, options?: HttpRequestOptions): Promise<ResponseResult<T>> {
    return this.request<T>(HttpMethod.PUT, url, data, options)
  }

  public async delete<T>(url: string, options?: HttpRequestOptions): Promise<ResponseResult<T>> {
    return this.request<T>(HttpMethod.DELETE, url, undefined, options)
  }
}
