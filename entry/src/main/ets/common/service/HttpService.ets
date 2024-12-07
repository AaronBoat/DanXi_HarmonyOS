import http from '@ohos.net.http'

/**
 * Type for dynamic object with string keys
 */
type DynamicObject = Record<string, string | number | boolean | null | undefined>

/**
 * Interface for HTTP headers
 */
interface HttpHeadersObject {
  'Content-Type'?: string
  [key: string]: string | undefined
}

/**
 * HTTP request configuration options
 */
interface HttpRequestOptions {
  method: http.RequestMethod
  header?: HttpHeadersObject
  extraData?: string
  connectTimeout?: number
}

/**
 * Options for HTTP request configuration
 */
interface HttpOptions {
  headers?: HttpHeadersObject
  timeout?: number
}

/**
 * Standardized HTTP response structure
 */
interface HttpResponse {
  data: Record<string, object>
  status: number
  headers: HttpHeadersObject
}

/**
 * Custom error for HTTP service
 */
class HttpServiceError extends Error {
  constructor(message: string) {
    super(message)
    this.name = 'HttpServiceError'
  }
}

/**
 * Centralized HTTP service for network requests
 */
@Observed
export class HttpService {
  // Singleton instance
  private static instance: HttpService | null = null

  // HTTP request handler
  private httpRequest: http.HttpRequest

  // Default timeout for network requests
  private readonly DEFAULT_TIMEOUT: number = 10000

  /**
   * Private constructor to enforce singleton pattern
   */
  private constructor() {
    this.httpRequest = http.createHttp()
  }

  /**
   * Get singleton instance of HttpService
   */
  public static getInstance(): HttpService {
    if (!HttpService.instance) {
      HttpService.instance = new HttpService()
    }
    return HttpService.instance
  }

  /**
   * Validate and prepare request data
   */
  private prepareRequestData(data: object): string {
    if (data && typeof data === 'object' && !Array.isArray(data)) {
      return JSON.stringify(data)
    }
    throw new HttpServiceError('Invalid request data')
  }

  /**
   * Create request options
   */
  private createRequestOptions(
    method: http.RequestMethod, 
    headers: HttpHeadersObject, 
    data?: string, 
    timeout?: number
  ): HttpRequestOptions {
    // Create a new object with default headers
    const mergedHeaders: HttpHeadersObject = {
      'Content-Type': 'application/json'
    }
    
    // Manually copy headers, ensuring type safety
    if (headers) {
      Object.keys(headers).forEach(key => {
        if (headers[key] !== undefined) {
          mergedHeaders[key] = headers[key]
        }
      })
    }

    return {
      method: method,
      header: mergedHeaders,
      extraData: data,
      connectTimeout: timeout ?? this.DEFAULT_TIMEOUT
    }
  }

  /**
   * Parse response data
   */
  private parseResponse(response: http.HttpResponse): HttpResponse {
    if (response.responseCode !== 200) {
      throw new HttpServiceError(`HTTP Error: ${response.responseCode}`)
    }

    try {
      // Convert headers to HttpHeadersObject
      const headers: HttpHeadersObject = {
        'Content-Type': 'application/json'
      }
      
      // Manually copy headers to avoid spread operator issues
      if (response.header) {
        Object.keys(response.header).forEach(key => {
          const value: string | number | boolean = response.header[key] as string | number | boolean
          
          // Explicit conversion to string
          if (value !== null && value !== undefined) {
            headers[key] = typeof value === 'string' 
              ? value 
              : String(value)
          }
        })
      }

      return {
        data: JSON.parse(response.result as string),
        status: response.responseCode,
        headers: headers
      }
    } catch (error) {
      throw new HttpServiceError('Failed to parse response')
    }
  }

  /**
   * Perform GET request
   */
  async get(
    url: string, 
    options?: HttpOptions
  ): Promise<HttpResponse> {
    try {
      // Create headers object manually
      const headers: HttpHeadersObject = {
        'Content-Type': 'application/json'
      }
      
      // Manually copy headers to avoid spread operator issues
      if (options?.headers) {
        Object.keys(options.headers).forEach(key => {
          if (options.headers[key] !== undefined) {
            headers[key] = options.headers[key]
          }
        })
      }

      const requestOptions = this.createRequestOptions(
        http.RequestMethod.GET, 
        headers, 
        undefined, 
        options?.timeout
      )
      
      const response = await this.httpRequest.request(url, requestOptions)
      return this.parseResponse(response)
    } catch (error) {
      const errorMessage = error instanceof Error 
        ? error.message 
        : 'Unknown GET request error'
      
      console.error('HTTP GET Error:', errorMessage)
      throw new HttpServiceError(errorMessage)
    }
  }

  /**
   * Perform POST request
   */
  async post(
    url: string, 
    data: object, 
    options?: HttpOptions
  ): Promise<HttpResponse> {
    try {
      // Create headers object manually
      const headers: HttpHeadersObject = {
        'Content-Type': 'application/json'
      }
      
      // Manually copy headers to avoid spread operator issues
      if (options?.headers) {
        Object.keys(options.headers).forEach(key => {
          if (options.headers[key] !== undefined) {
            headers[key] = options.headers[key]
          }
        })
      }

      const preparedData = this.prepareRequestData(data)
      
      const requestOptions = this.createRequestOptions(
        http.RequestMethod.POST, 
        headers, 
        preparedData, 
        options?.timeout
      )
      
      const response = await this.httpRequest.request(url, requestOptions)
      return this.parseResponse(response)
    } catch (error) {
      const errorMessage = error instanceof Error 
        ? error.message 
        : 'Unknown POST request error'
      
      console.error('HTTP POST Error:', errorMessage)
      throw new HttpServiceError(errorMessage)
    }
  }

  /**
   * Perform PUT request
   */
  async put(
    url: string, 
    data: object, 
    options?: HttpOptions
  ): Promise<HttpResponse> {
    try {
      // Create headers object manually
      const headers: HttpHeadersObject = {
        'Content-Type': 'application/json'
      }
      
      // Manually copy headers to avoid spread operator issues
      if (options?.headers) {
        Object.keys(options.headers).forEach(key => {
          if (options.headers[key] !== undefined) {
            headers[key] = options.headers[key]
          }
        })
      }

      const preparedData = this.prepareRequestData(data)
      
      const requestOptions = this.createRequestOptions(
        http.RequestMethod.PUT, 
        headers, 
        preparedData, 
        options?.timeout
      )
      
      const response = await this.httpRequest.request(url, requestOptions)
      return this.parseResponse(response)
    } catch (error) {
      const errorMessage = error instanceof Error 
        ? error.message 
        : 'Unknown PUT request error'
      
      console.error('HTTP PUT Error:', errorMessage)
      throw new HttpServiceError(errorMessage)
    }
  }

  /**
   * Perform DELETE request
   */
  async delete(
    url: string, 
    options?: HttpOptions
  ): Promise<HttpResponse> {
    try {
      // Create headers object manually
      const headers: HttpHeadersObject = {
        'Content-Type': 'application/json'
      }
      
      // Manually copy headers to avoid spread operator issues
      if (options?.headers) {
        Object.keys(options.headers).forEach(key => {
          if (options.headers[key] !== undefined) {
            headers[key] = options.headers[key]
          }
        })
      }

      const requestOptions = this.createRequestOptions(
        http.RequestMethod.DELETE, 
        headers, 
        undefined, 
        options?.timeout
      )
      
      const response = await this.httpRequest.request(url, requestOptions)
      return this.parseResponse(response)
    } catch (error) {
      const errorMessage = error instanceof Error 
        ? error.message 
        : 'Unknown DELETE request error'
      
      console.error('HTTP DELETE Error:', errorMessage)
      throw new HttpServiceError(errorMessage)
    }
  }

  /**
   * Release HTTP resources
   */
  public release(): void {
    if (this.httpRequest) {
      this.httpRequest.destroy()
      HttpService.instance = null
    }
  }
}
