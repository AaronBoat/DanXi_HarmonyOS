import { CourseService } from '../common/service/CourseService'
import { TimeTableModel } from '../common/model/TimeTableModel'
import promptAction from '@ohos.promptAction'
import router from '@ohos.router'
import { Course } from '../common/model/CourseModel';

@Entry
@Component
export default struct CourseTablePage {
  @State courses: Course[] = []
  @State isLoading: boolean = true
  private courseService: CourseService = CourseService.getInstance()

  @Builder
  private courseGridItem(course: TimeTableModel, row: number, col: number) {
    if (this.isCourseInCell(course, row, col)) {
      Row() {
        Text(course.name)
          .fontSize(12)
          .fontColor(Color.White)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(course.color || '#3366FF')
      .borderRadius(4)
      .padding(4)
      .onClick(() => this.showCourseDetail(course))
    }
  }

  private isCourseInCell(course: TimeTableModel, row: number, col: number): boolean {
    return course.weekday === col && 
           row >= course.startSection && 
           row <= course.endSection
  }

  private async showCourseDetail(course: TimeTableModel): Promise<void> {
    try {
      await router.pushUrl({
        url: 'pages/CourseDetailPage',
        params: { courseId: course.id }
      })
    } catch (error) {
      console.error('Navigation to course detail failed:', error)
      promptAction.showToast({ 
        message: '无法打开课程详情',
        duration: 2000 
      })
    }
  }

  async aboutToAppear(): Promise<void> {
    try {
      this.isLoading = true
      this.courses = await this.courseService.getCourseTable()
    } catch (error) {
      console.error('加载课程表失败:', error)
      promptAction.showToast({ 
        message: '加载课程表失败，请稍后重试',
        duration: 2000 
      })
    } finally {
      this.isLoading = false
    }
  }

  build(): void {
    Column() {
      if (this.isLoading) {
        LoadingProgress()
          .color(Color.Blue)
          .width(50)
          .height(50)
      } else if (this.courses.length === 0) {
        Text('暂无课程')
          .fontSize(16)
          .fontColor(Color.Gray)
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ top: 20 })
      } else {
        Grid() {
          // 星期头部
          ForEach(['一', '二', '三', '四', '五', '六', '日'], (day:string, index:number) => {
            GridItem() {
              Text(day)
                .fontSize(12)
                .fontColor(Color.Gray)
                .width('100%')
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .height(30)
          })

          // 节次头部
          ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], (section:number) => {
            GridItem() {
              Text(section.toString())
                .fontSize(12)
                .fontColor(Color.Gray)
                .width('100%')
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .height(50)
          })

          // 课程网格
          ForEach(this.courses, (course:TimeTableModel) => {
            GridItem() {
              this.courseGridItem(course, course.startSection, course.weekday)
            }
            .columnStart(course.startSection)
            .columnEnd(course.endSection + 1)
            .rowStart(course.weekday + 1)
            .rowEnd(course.weekday + 2)
          })
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
        .rowsTemplate('30px repeat(12, 1fr)')
        .height('100%')
        .width('100%')
        .backgroundColor(Color.White)
        .padding(10)
      }

      Button('导出到日历')
        .width('90%')
        .margin({ top: 10 })
        .onClick(async (): Promise<void> => {
          if (this.courses.length === 0) {
            promptAction.showToast({
              message: '没有可导出的课程',
              duration: 2000
            })
            return
          }

          const exportPromises = this.courses.map(course => 
            this.courseService.exportCourseToCalendar(course.courseId)
          )
          
          try {
            const results = await Promise.all(exportPromises)
            const successCount = results.filter(result => result).length
            
            if (successCount > 0) {
              promptAction.showToast({
                message: `成功导出 ${successCount} / ${this.courses.length} 门课程`,
                duration: 2000
              })
            } else {
              promptAction.showToast({
                message: '导出课程失败，请稍后重试',
                duration: 2000
              })
            }
          } catch (error) {
            console.error('课程导出失败:', error)
            promptAction.showToast({
              message: '导出课程时发生错误',
              duration: 2000
            })
          }
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F4')
  }
}
