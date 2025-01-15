import HttpService from './HttpService'
import { ResponseResult } from '../model/ResponseResult'
import { TimeTableModel } from '../model/TimeTableModel'
import storage from '@ohos.data.storage'
import { Course } from '../model/CourseModel'

interface CourseInterface {
  id: string
  name: string
  teacher: string
  location: string
  time: string
  credit: number
  type: string
}

export interface CourseDetail extends CourseInterface {
  semester: string
  weekRange: string
  classTime: string
  classType: string
}

export class CourseService {
  private static _instance: CourseService | null = null
  private httpService: HttpService
  private storagePreferences: storage.Storage | null = null

  private constructor() {
    this.httpService = HttpService.getInstance()
  }

  public static getInstance(): CourseService {
    if (!CourseService._instance) {
      CourseService._instance = new CourseService()
    }
    return CourseService._instance
  }

  private async initStorage(): Promise<void> {
    if (!this.storagePreferences) {
      this.storagePreferences = await storage.getStorage('course_preferences')
    }
  }

  public async getCourseTable(): Promise<Course[]> {
    try {
      const response: ResponseResult<Course[]> = await this.httpService.get('/course/table', { needToken: true })
      if (response.code === 200 && response.data) {
        await this.cacheCourseTable(response.data)
        return response.data
      } else {
        const cachedTable = await this.getCachedCourseTable()
        return cachedTable || []
      }
    } catch (error) {
      console.error('获取课程表失败:', error)
      const cachedTable = await this.getCachedCourseTable()
      return cachedTable || []
    }
  }

  public async getCourseDetail(courseId: string): Promise<CourseDetail | null> {
    try {
      const response: ResponseResult<CourseDetail> = await this.httpService.get(`/course/detail/${courseId}`, { needToken: true })
      if (response.code === 200) {
        return response.data ?? null
      } else {
        throw new Error('Failed to fetch course detail')
      }
    } catch (error) {
      console.error('获取课程详情失败:', error)
      return null
    }
  }

  public async getNextCourse(): Promise<Course | null> {
    try {
      const response: ResponseResult<Course> = await this.httpService.get('/course/next', { needToken: true })
      if (response.code === 200) {
        return response.data ?? null
      } else {
        throw new Error('Failed to fetch next course')
      }
    } catch (error) {
      console.error('获取下一节课失败:', error)
      return null
    }
  }

  private async cacheCourseTable(courses: Course[]): Promise<void> {
    try {
      await this.initStorage()
      if (this.storagePreferences) {
        await this.storagePreferences.put('course_table', JSON.stringify(courses))
        await this.storagePreferences.flush()
      }
    } catch (error) {
      console.error('缓存课程表失败:', error)
    }
  }

  private async getCachedCourseTable(): Promise<Course[] | null> {
    try {
      await this.initStorage()
      if (this.storagePreferences) {
        const cachedTable = this.storagePreferences.get('course_table', 'not_found')
        return cachedTable ? JSON.parse(cachedTable.toString()) : null
      }
      return null
    } catch (error) {
      console.error('读取缓存课程表失败:', error)
      return null
    }
  }

  public async exportCourseToCalendar(courseId: string): Promise<boolean> {
    try {
      const courseDetail = await this.getCourseDetail(courseId)
      if (courseDetail) {
        // Implement calendar export logic here
        return true
      }
      return false
    } catch (error) {
      console.error('Error exporting course to calendar:', error)
      return false
    }
  }
}
