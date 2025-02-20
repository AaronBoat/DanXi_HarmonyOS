import router from '@ohos.router';

@Entry
@Component
struct SplashPage {
  aboutToAppear() {
    setTimeout(() => {
      router.replaceUrl({ url: 'pages/LoginPage' });
    },500);
  }

  build() {
    Column() {
      Image($r('app.media.danxi_cat'))
        .width(80)
        .height(80)
        .objectFit(ImageFit.Contain)
        .borderRadius(16)
    }
    .width('100%')
    .height('100%')
//    .backgroundColor('#0099FF')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
} 