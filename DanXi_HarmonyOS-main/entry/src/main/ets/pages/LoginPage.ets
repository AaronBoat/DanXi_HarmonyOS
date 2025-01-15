import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { CommonConstants } from '../common/constants/CommonConstants';
import { LoginService } from '../common/services/LoginService';
import { UserGroup } from '../models/UserInfo';

@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State errorText: string = '';
  @State private loginType: 'dantan' | 'uis' = 'dantan';

  private loginService: LoginService = LoginService.getInstance();

  async aboutToAppear(): Promise<void> {
    await this.loginService.init();
  }

  async login(): Promise<void> {
    if (!this.username || !this.password) {
      this.errorText = '请输入用户名和密码';
      return;
    }

    this.isLoading = true;
    this.errorText = '';

    try {
      if (this.loginType === 'dantan') {
        await this.loginService.dantanLogin(this.username, this.password);
      } else {
        await this.loginService.uisLogin(this.username, this.password);
      }
      router.replaceUrl({ url: CommonConstants.DEFAULT_PAGE });
    } catch (error) {
      this.handleLoginError(error);
    } finally {
      this.isLoading = false;
    }
  }

  handleLoginError(error: Error) {
    let errorMessage = '登录失败';

    switch (error.message) {
      case '密码错误':
        errorMessage = '用户名或密码错误';
        break;
      case '需要输入验证码':
        errorMessage = '需要输入验证码，请使用浏览器登录';
        break;
      case '系统维护中':
        errorMessage = '系统维护中，请稍后再试';
        break;
      case '网络错误':
        errorMessage = '网络连接失败，请检查网络设置';
        break;
      default:
        errorMessage = error.message || '登录失败，请稍后重试';
    }

    this.errorText = errorMessage;
    promptAction.showToast({
      message: errorMessage,
      duration: 2000
    });
  }

  @Builder
  loginHeader(): void {
    Column() {
      Stack() {
        Column()
          .width(80)
          .height(80)
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
          .shadow({
            radius: 16,
            color: '#00000015',
            offsetX: 0,
            offsetY: 2
          })
        
        Image($r('app.media.logo'))
          .width(80)
          .height(80)
          .objectFit(ImageFit.Contain)
          .borderRadius(16)
      }
      .margin({ top: 32, bottom: 12 })
      
      Text('登录旦挞')
        .fontSize(22)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .margin({ bottom: 2 })
      
      Text('欢迎回来')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 20 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  loginTypeSelector() {
    Row() {
      // 旦挞账号登录选项
      Column() {
        Text('旦挞账号')
          .fontSize(16)
          .fontColor(this.loginType === 'dantan' ? '#2B5AED' : '#999999')
          .fontWeight(this.loginType === 'dantan' ? FontWeight.Medium : FontWeight.Normal)
        
        // 底部指示条
        Row()
          .width(40)
          .height(3)
          .backgroundColor(this.loginType === 'dantan' ? '#2B5AED' : 'transparent')
          .margin({ top: 8 })
          .borderRadius(1.5)
      }
      .onClick(() => {
        this.loginType = 'dantan';
        this.errorText = '';
      })
      .margin({ right: 40 })

      // 复旦UIS登录选项
      Column() {
        Text('复旦UIS')
          .fontSize(16)
          .fontColor(this.loginType === 'uis' ? '#2B5AED' : '#999999')
          .fontWeight(this.loginType === 'uis' ? FontWeight.Medium : FontWeight.Normal)
        
        // 底部指示条
        Row()
          .width(40)
          .height(3)
          .backgroundColor(this.loginType === 'uis' ? '#2B5AED' : 'transparent')
          .margin({ top: 8 })
          .borderRadius(1.5)
      }
      .onClick(() => {
        this.loginType = 'uis';
        this.errorText = '';
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin({ bottom: 24 })
  }

  @Builder
  loginForm(): void {
    Column() {
      this.loginTypeSelector()

      // 用户名输入框
      Column() {
        Text(this.loginType === 'dantan' ? '用户名' : '学号')
          .fontSize(14)
          .fontColor('#666666')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 4, left: 4 })
        
        TextInput({ 
          placeholder: this.loginType === 'dantan' ? '请输入用户名' : '请输入学号',
          text: this.username 
        })
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .padding({ left: 16 })
          .placeholderColor('#999999')
          .onChange((value: string) => {
            this.username = value;
          })
      }
      .margin({ bottom: 16 })
      .width('90%')

      // 密码输入框
      Column() {
        Text('密码')
          .fontSize(14)
          .fontColor('#666666')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8, left: 4 })
        
        TextInput({ 
          placeholder: this.loginType === 'dantan' ? '请输入密码' : '请输入UIS密码',
          text: this.password 
        })
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .padding({ left: 16 })
          .placeholderColor('#999999')
          .type(InputType.Password)
          .onChange((value: string) => {
            this.password = value;
          })
      }
      .margin({ bottom: 16 })
      .width('90%')

      // 错误提示
      Text(this.errorText)
        .fontSize(14)
        .fontColor('#FF4D4F')
        .margin({ bottom: 24 })
        .opacity(this.errorText ? 1 : 0)

      // 登录按钮
      Button(this.isLoading ? '登录中...' : '登录')
        .width('90%')
        .height(50)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#2B5AED')
        .borderRadius(25)
        .margin({ bottom: 12 })
        .enabled(!this.isLoading)
        .onClick(() => {
          this.login();  // 直接调用 login() 方法，它会根据 loginType 选择正确的登录方式
        })

      Row() {
        Text(this.loginType === 'dantan' ? '没有账号？立即注册' : '忘记密码？')
          .fontSize(14)
          .fontColor('#666666')
          .onClick(() => {
            if (this.loginType === 'dantan') {
              promptAction.showToast({
                message: '注册功能开发中',
                duration: 2000
              });
            } else {
              promptAction.showToast({
                message: '请联系管理员找回密码',
                duration: 2000
              });
            }
          })
      }
      .margin({ top: 4, bottom: 20 })

      // 添加说明文字区域
      Column() {
        // 核心信息
        Text('两个独立账号系统')
          .fontSize(15)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 12 })

        Row() {
          // 左侧：旦挞账号说明
          Column() {
            Text('旦挞账号')
              .fontSize(13)
              .fontColor('#2B5AED')
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 4 })
            Text('社区功能')
              .fontSize(11)
              .fontColor('#666666')
              .fontWeight(FontWeight.Regular)
          }
          .alignItems(HorizontalAlign.Center)
          .layoutWeight(1)

          // 分隔线
          Divider()
            .vertical(true)
            .height(44)  // 稍微加高一点
            .color('#EEEEEE')
            .margin({ left: 16, right: 16 })

          // 右侧：UIS账号说明
          Column() {
            Text('复旦UIS')
              .fontSize(13)
              .fontColor('#2B5AED')
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 4 })
            Text('教务功能')
              .fontSize(11)
              .fontColor('#666666')
              .fontWeight(FontWeight.Regular)
          }
          .alignItems(HorizontalAlign.Center)
          .layoutWeight(1)
        }
        .width('90%')
        .margin({ top: 4, bottom: 8 })

        Text('可随时切换或同时登录两个账号')
          .fontSize(12)
          .fontColor('#666666')
          .fontWeight(FontWeight.Regular)
          .margin({ bottom: 4 })

        Text('登入旦挞后可同时登录另一账号')
          .fontSize(12)
          .fontColor('#666666')
          .fontWeight(FontWeight.Regular)
      }
      .backgroundColor('#F8F9FE')
      .width('90%')
      .padding({ top: 16, bottom: 16, left: 16, right: 16 })
      .borderRadius(16)
      .border({ width: 1, color: '#E8EFFF' })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  build(): void {
    Stack() {
      // 背景装饰
      Column() {
        Circle()
          .width(200)
          .height(200)
          .fill('#2B5AED10')
          .position({ x: -100, y: -100 })
        
        Circle()
          .width(150)
          .height(150)
          .fill('#2B5AED08')
          .position({ x: 300, y: 500 })
      }
      
      // 主要内容
      Scroll() {  // 添加滚动容器
        Column() {
          this.loginHeader()
          this.loginForm()
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 20 })  // 添加底部内边距
        .justifyContent(FlexAlign.Start)  // 从顶部开始布局
      }
      .scrollBar(BarState.Off)  // 隐藏滚动条
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}

export default LoginPage;