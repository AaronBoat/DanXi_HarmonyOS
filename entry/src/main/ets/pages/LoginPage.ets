import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AuthService } from '../common/service/AuthService';
import http from '@ohos.net.http';
import { StorageService } from '../common/service/StorageService';
import { CommonConstants } from '../common/constants/CommonConstants';

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
  @State standard_output: string = 'standard output（测试）';

  private authService: AuthService = AuthService.getInstance();
  private storageService: StorageService | null = null;

  async aboutToAppear(): Promise<void> {
    this.storageService = await StorageService.getInstance();
  }

  async login(): Promise<void> {
    if (!this.username || !this.password) {
      this.errorText = '请输入用户名和密码';
      return;
    }

    this.isLoading = true;
    this.errorText = '';

    try {
      switch (this.userGroup) {
        case UserGroup.VISITOR:
          await this.visitorLogin();
          break;
        case UserGroup.FUDAN_UNDERGRADUATE_STUDENT:
        case UserGroup.FUDAN_POSTGRADUATE_STUDENT:
          await this.uisLogin();
          break;
      }
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
      this.standard_output = loginPageContent; // 测试
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
    this.standard_output = responseText;
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
      Image($r(CommonConstants.APP_ICON))
        .width(100)
        .height(100)
        .margin({ top: 50, bottom: 20 })

      Text('登录')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  loginForm(): void {
    Column() {
      // 用户组选择
      Row() {
        ForEach(Object.values(UserGroup), (group: UserGroup) => {
          Button(Reflect.get(kUserGroupDescription, group))
            .backgroundColor(this.userGroup === group ? CommonConstants.SELECTED_BUTTON_COLOR : CommonConstants.UNSELECTED_BUTTON_COLOR)
            .fontColor(this.userGroup === group ? Color.White : Color.Black)
            .margin({ right: 10 })
            .onClick(() => {
              this.userGroup = group;
              this.standard_output = group; // 测试
            })
        })
      }
      .margin({ bottom: 20 })

      // 用户名输入
      TextInput({
        placeholder: '请输入用户名',
        text: this.username
      })
        .width('90%')
        .height(50)
        .margin({ bottom: 15 })
        .backgroundColor(Color.White)
        .borderRadius(10)
        .padding({ left: 15 })
        .onChange((value: string) => {
          this.username = value;
        })

      // 密码输入
      TextInput({
        placeholder: '请输入密码',
        text: this.password
      })
        .width('90%')
        .height(50)
        .margin({ bottom: 10 })
        .backgroundColor(Color.White)
        .borderRadius(10)
        .padding({ left: 15 })
        .type(InputType.Password)
        .onChange((value: string) => {
          this.password = value;
        })

      // 错误提示
      Text(this.errorText)
        .fontSize(14)
        .fontColor(Color.Red)
        .margin({ bottom: 10 })
        .opacity(this.errorText ? 1 : 0)

      // 登录按钮
      Button(this.isLoading ? '登录中...' : '登录')
        .width('90%')
        .height(50)
        .backgroundColor('#1698CE')
        .borderRadius(10)
        .margin({ bottom: 15 })
        .enabled(!this.isLoading)
        .onClick(() => {
          this.login();
          this.standard_output = "正在登录..."; // 测试
        })

      // 忘记密码
      Text('忘记密码？')
        .fontSize(14)
        .fontColor(Color.Gray)
        .onClick(() => {
          promptAction.showToast({
            message: '请联系管理员找回密码',
            duration: 2000
          });
        })

      // 标准输出（测试用）
      Text(this.standard_output)
        .fontSize(10)
        .fontColor(Color.White)
        .backgroundColor(Color.Black)
        .width("90%")
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  build(): void {
    Column() {
      // 顶部空白区域
      Blank().height('10%')

      // 登录头部
      this.loginHeader()

      // 登录表单
      this.loginForm()

      // 底部空白区域
      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
    .padding({ left: 20, right: 20 })
  }
}

export default LoginPage;
