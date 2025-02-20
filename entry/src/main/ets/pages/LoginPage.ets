import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AuthService } from '../common/service/AuthService';
import http from '@ohos.net.http';
import { StorageService } from '../common/service/StorageService';
import { CommonConstants } from '../common/constants/CommonConstants';
import window from '@ohos.window';

enum UserGroup {
  FUDAN_UNDERGRADUATE_STUDENT = 'FUDAN_UNDERGRADUATE_STUDENT',
  FUDAN_POSTGRADUATE_STUDENT = 'FUDAN_POSTGRADUATE_STUDENT',
  VISITOR = 'VISITOR'
}

interface UserGroupDescription {
  FUDAN_UNDERGRADUATE_STUDENT: string;
  FUDAN_POSTGRADUATE_STUDENT: string;
  VISITOR: string;
}

const kUserGroupDescription: UserGroupDescription = {
  FUDAN_UNDERGRADUATE_STUDENT: '本科生',
  FUDAN_POSTGRADUATE_STUDENT: '研究生',
  VISITOR: '游客'
};

interface UserInfo {
  id: string;
  password: string;
  name: string;
  userGroup: UserGroup;
}

@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State userGroup: UserGroup = UserGroup.FUDAN_UNDERGRADUATE_STUDENT;
  @State errorText: string = '';
  @State keyboardHeight: number = 0;
  
  private authService: AuthService = AuthService.getInstance();
  private storageService: StorageService | null = null;
  private context = getContext(this);

  async aboutToAppear(): Promise<void> {
    this.storageService = await StorageService.getInstance();
    // 获取当前窗口并设置键盘属性
    try {
      let windowClass = await window.getLastWindow(this.context);
      windowClass.on('keyboardHeightChange', (height: number) => {
        this.keyboardHeight = height;
      });
    } catch (error) {
      console.error('Failed to get window:', error);
    }
  }

  aboutToDisappear() {
    // 移除键盘监听
    window.getLastWindow(this.context).then(windowClass => {
      windowClass.off('keyboardHeightChange');
    }).catch((error: Error) => {
      console.error('Failed to remove keyboard listener:', error.message);
    });
  }

  async login(): Promise<void> {
    if (!this.username || !this.password) {
      this.errorText = '请输入用户名和密码';
      return;
    }

    this.isLoading = true;
    this.errorText = '';

    try {
      await this.uisLogin();
    } catch (error) {
      this.handleLoginError(error);
    } finally {
      this.isLoading = false;
    }
  }

  async visitorLogin(): Promise<void> {
    let userInfo: UserInfo = {
      id: this.username,
      password: this.password,
      name: '游客',
      userGroup: UserGroup.VISITOR
    };
    await this.storageService?.setObject('userInfo', userInfo);
    router.replaceUrl({ url: CommonConstants.DEFAULT_PAGE });
  }

  async uisLogin(): Promise<void> {
    const loginUrl: string = CommonConstants._LOGIN_URL;
    const httpRequest = http.createHttp();

    try {
      // 第一步：获取登录页面
      const loginPageResponse = await httpRequest.request(loginUrl, {
        method: http.RequestMethod.GET
      });

      // 解析登录页面，获取隐藏的表单字段
      const loginPageContent = loginPageResponse.result as string;
      const formData = this.parseLoginForm(loginPageContent);
      formData['username'] = this.username;
      formData['password'] = this.password;

      // 第二步：提交登录表单
      const loginResponse = await httpRequest.request(loginUrl, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        extraData: this.encodeFormData(formData)
      });

      // 检查登录结果
      const responseText = loginResponse.result as string;
      this.checkLoginResponse(responseText);

      // 保存用户信息
      let userInfo: UserInfo = {
        id: this.username,
        password: this.password,
        name: await this.fetchStudentName(),
        userGroup: this.userGroup
      };
      await this.storageService?.setObject('userInfo', userInfo);

      router.replaceUrl({ url: CommonConstants.DEFAULT_PAGE });
    } catch (error) {
      throw error as Error;
    } finally {
      httpRequest.destroy();
    }
  }

  parseLoginForm(html: string): Record<string, string> {
    const formData: Record<string, string> = {};
    const inputMatches = html.match(/<input[^>]+name="([^"]+)"[^>]+value="([^"]*)"[^>]*>/g);

    if (inputMatches) {
      for (const match of inputMatches) {
        const nameMatch = match.match(/name="([^"]+)"/);
        const valueMatch = match.match(/value="([^"]*)"/);

        if (nameMatch && valueMatch) {
          formData[nameMatch[1]] = valueMatch[1];
        }
      }
    }

    return formData;
  }

  encodeFormData(data: Record<string, string>): string {
    return Object.entries(data)
      .map((keyValue) => {
        const key = keyValue[0];
        const value = keyValue[1];
        return `${encodeURIComponent(key)}=${encodeURIComponent(value)}`;
      })
      .join('&');
  }

  checkLoginResponse(responseText: string) {
    if (responseText.includes('密码有误')) {
      throw new Error('密码错误');
    }
    if (responseText.includes('请输入验证码')) {
      throw new Error('需要输入验证码');
    }
    if (responseText.includes('网络维护中')) {
      throw new Error('系统维护中');
    }
    throw new Error('密码错误'); // 测试
  }

  async fetchStudentName(): Promise<string> {
    // TODO: 实现获取学生姓名的逻辑
    return this.username;
  }

  handleLoginError(error: Error) {
    let errorMessage = '登录失败';

    switch (error.message) {
      case '密码错误':
        errorMessage = '用户名或密码错误';
        break;
      case '需要输入验证码':
        errorMessage = '需要输入验证码，请手动登录';
        break;
      case '系统维护中':
        errorMessage = '系统维护中，请稍后再试';
        break;
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
      Image($r('app.media.danxi_cat'))
        .width(70)
        .height(70)
        .margin({ top: 120, bottom: 40 })
        .objectFit(ImageFit.Contain)
        .borderRadius(24)  // 添加圆角，遵循现代设计趋势
        .shadow({  // 添加轻微阴影效果
          radius: 20,
          color: '#00000020',
          offsetX: 0,
          offsetY: 4
        })

      Text('复旦本科生 UIS 登录')
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor('#003153')
        .margin({ bottom: 60 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  loginForm(): void {
    Column() {
      // 用户名输入
      Row() {
        Image($r('app.media.icon_user'))  // 请确保添加了对应的图标资源
          .width(20)
          .height(20)
          .margin({ right: 12 })
          .fillColor('#666666')
        
        TextInput({
          placeholder: '学号',
          text: this.username
        })
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .padding({ left: 16 })
          .onChange((value: string) => {
            this.username = value;
          })
      }
      .width('100%')
      .margin({ bottom: 16 })
      .alignItems(VerticalAlign.Center)

      // 密码输入
      Row() {
        Image($r('app.media.icon_lock'))  // 请确保添加了对应的图标资源
          .width(20)
          .height(20)
          .margin({ right: 12 })
          .fillColor('#666666')
        
        TextInput({
          placeholder: '密码',
          text: this.password
        })
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .padding({ left: 16 })
          .type(InputType.Password)
          .onChange((value: string) => {
            this.password = value;
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      // 错误提示
      Text(this.errorText)
        .fontSize(14)
        .fontColor('#FF3B30')
        .margin({ top: 8 })
        .opacity(this.errorText ? 1 : 0)

      // 登录按钮
      Button(this.isLoading ? '登录中...' : '登录')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#003153')
        .borderRadius(8)
        .margin({ top: 32 })
        .enabled(!this.isLoading)
        .onClick(() => {
          this.login();
        })

      // 忘记密码
      Text('忘记密码？')
        .fontSize(14)
        .fontColor('#003153')
        .margin({ top: 16 })
        .onClick(() => {
          promptAction.showToast({
            message: '请访问 UIS 网站重置密码',
            duration: 2000
          });
        })
    }
    .width('100%')
    .padding({ left: 24, right: 24 })
  }

  build(): void {
    Column() {
      Scroll() {
        Column() {
          this.loginHeader()
          this.loginForm()
          Blank()
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Color.White)
        .padding({ bottom: this.keyboardHeight }) // 添加键盘高度的padding
      }
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
  }
}

export default LoginPage;
