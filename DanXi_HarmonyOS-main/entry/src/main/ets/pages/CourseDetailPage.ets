import router from '@ohos.router'
import { CourseService, CourseDetail } from '../common/service/CourseService'

@Entry
@Component
export default struct CourseDetailPage {
  @State courseDetail: CourseDetail | null = null
  @State isLoading: boolean = true
  private courseId: string = ''
  private courseService: CourseService = CourseService.getInstance()

  async aboutToAppear() {
    const params = router.getParams() as Record<string, string>
    this.courseId = params['courseId']

    try {
      this.isLoading = true
      this.courseDetail = await this.courseService.getCourseDetail(this.courseId)
    } catch (error) {
      console.error('获取课程详情失败:', error)
    } finally {
      this.isLoading = false
    }
  }

  @Builder
  private detailItem(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor(Color.Gray)
        .width('30%')
      Text(value)
        .fontSize(14)
        .fontColor(Color.Black)
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r(`app.media.back`))
          .width(24)
          .height(24)
          .margin({ right: 10 })
          .onClick(() => router.back())
        Text('课程详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding(15)
      .backgroundColor(Color.White)

      if (this.isLoading) {
        LoadingProgress()
          .color(Color.Blue)
          .width(50)
          .height(50)
          .margin({ top: 20 })
      } else if (!this.courseDetail) {
        Text('未找到课程详情')
          .fontSize(16)
          .fontColor(Color.Gray)
          .margin({ top: 20 })
      } else {
        Column() {
          // 课程基本信息卡片
          Column() {
            Text(this.courseDetail.name)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 10 })
            
            this.detailItem('教师', this.courseDetail.teacher)
            this.detailItem('地点', this.courseDetail.location)
            this.detailItem('学分', this.courseDetail.credit.toString())
            this.detailItem('学期', this.courseDetail.semester)
            this.detailItem('上课时间', this.courseDetail.time)
            this.detailItem('课程类型', this.courseDetail.classType)
          }
          .width('100%')
          .padding(15)
          .backgroundColor(Color.White)
          .borderRadius(10)
          .margin(15)

          // 操作按钮
          Row() {
            Button('导出到日历')
              .width('45%')
              .margin({ right: 10 })
              .onClick(async () => {
                const success = await this.courseService.exportCourseToCalendar(this.courseId)
                AlertDialog.show({
                  title: '导出结果',
                  message: success ? '课程已成功导出到日历' : '导出失败',
                  confirm: {
                    value: '确定',
                    action: () => {}
                  }
                })
              })

            Button('返回课表')
              .width('45%')
              .onClick(() => router.back())
          }
          .width('100%')
          .padding(15)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#F1F3F4')
      }
    }
    .width('100%')
    .height('100%')
  }
}
