import http from '@ohos.net.http'
import { ResponseResult } from '../model/ResponseResult'
import HttpRequest from '@ohos.net.http'
import HttpResponse from '@ohos.net.http'

// 使用http模块中定义的RequestMethod类型
export type HttpMethod = http.RequestMethod;

export interface HttpRequestOptions {
  headers?: Record<string, string>
  timeout?: number
  needToken?: boolean
}

@Observed
export default class HttpService {
  private static _instance: HttpService | null = null
  private baseUrl: string = 'https://danxi.fduhole.com/api'; // 修正了URL
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
    data?: Record<string, Object>,
    options?: HttpRequestOptions
  ): Promise<ResponseResult<T>> {
    const fullUrl = `${this.baseUrl}${url}`
    const headers = options?.headers || {}
    if (options?.needToken && this.token) {
      headers['Authorization'] = `Bearer ${this.token}`
    }

    const requestOptions: http.HttpRequestOptions = {
      method,
      header: headers,
      connectTimeout: options?.timeout || this.defaultTimeout,
      readTimeout: options?.timeout || this.defaultTimeout,
      extraData: data ? JSON.stringify(data) : undefined
    }

    try {
      let httpRequest = http.createHttp();
      const response = await httpRequest.request(fullUrl, requestOptions)
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as ResponseResult<T>
      } else {
        throw new Error(`HTTP Error: ${response.responseCode}`)
      }
    } catch (error) {
      console.error('HTTP request failed:', error)
      throw Error(error)
    }
  }

  public async get<T>(url: string, options?: HttpRequestOptions): Promise<ResponseResult<T>> {
    return this.request<T>(http.RequestMethod.GET, url, undefined, options)
  }

  public async post<T>(url: string, data: Record<string, Object>, options?: HttpRequestOptions): Promise<ResponseResult<T>> {
    return this.request<T>(http.RequestMethod.POST, url, data, options)
  }

  public async put<T>(url: string, data: Record<string, Object>, options?: HttpRequestOptions): Promise<ResponseResult<T>> {
    return this.request<T>(http.RequestMethod.PUT, url, data, options)
  }

  public async delete<T>(url: string, options?: HttpRequestOptions): Promise<ResponseResult<T>> {
    return this.request<T>(http.RequestMethod.DELETE, url, undefined, options)
  }

  public async get(url: string): Promise<HttpResponse> {
    const request = new HttpRequest();
    request.url = url;
    request.method = 'GET';
    return await request.send();
  }

  public async post(url: string, data: Record<string, any>): Promise<HttpResponse> {
    const request = new HttpRequest();
    request.url = url;
    request.method = 'POST';
    request.data = data;
    return await request.send();
  }

  public setOptions(options: any) {
    // 设置请求的默认选项
  }

  async fetchDataWithParams(url: string, params: Record<string, any>): Promise<HttpResponse> {
    // 实现带参数的获取数据
  }
}