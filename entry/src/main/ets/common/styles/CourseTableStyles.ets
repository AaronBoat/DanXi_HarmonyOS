/**
 * Course table styles
 */

// 定义接口描述 Colors 对象的结构
interface ColorsInterface {
  primary: string;
  white: string;
  grayLight: string;
  courseCards: string[];
}

// 使用接口类型替代任何类型
// 颜色
export const Colors: ColorsInterface = {
  primary: '#2196F3',
  white: '#FFFFFF',
  grayLight: '#F5F5F5',
  courseCards: [
    '#FF7043', // Deep Orange
    '#42A5F5', // Blue
    '#66BB6A', // Green
    '#FFA726', // Orange
    '#AB47BC', // Purple
    '#EC407A', // Pink
    '#26A69A', // Teal
    '#5C6BC0'  // Indigo
  ]
};

// 定义接口描述 Sizes 对象的结构
interface SizesInterface {
  spacingTiny: number;
  spacingSmall: number;
  spacingNormal: number;
  spacingLarge: number;

  radiusSmall: number;
  radiusNormal: number;
  radiusLarge: number;

  shadowRadius: number;
  shadowOffsetX: number;
  shadowOffsetY: number;
  shadowColor: string;
  shadowColorDark: string;

  borderWidth: number;
}

// 使用接口类型替代任何类型
// 尺寸
export const Sizes: SizesInterface = {
  // 间距
  spacingTiny: 4,
  spacingSmall: 8,
  spacingNormal: 12,
  spacingLarge: 16,
  
  // 圆角
  radiusSmall: 4,
  radiusNormal: 8,
  radiusLarge: 12,
  
  // 阴影
  shadowRadius: 8,
  shadowOffsetX: 0,
  shadowOffsetY: 2,
  shadowColor: '#00000014',
  shadowColorDark: '#00000029',
  
  // 边框
  borderWidth: 1
};

// 文本样式接口
interface TextStyleInterface {
  fontSize: number;
  fontWeight: FontWeight;
  opacity: number;
}

// 排版接口
interface TypographyInterface {
  titleLarge: TextStyleInterface;
  titleNormal: TextStyleInterface;
  titleSmall: TextStyleInterface;
  bodyNormal: TextStyleInterface;
  bodySmall: TextStyleInterface;
  caption: TextStyleInterface
}

// 排版
export const Typography: TypographyInterface = {
  // 标题
  titleLarge: {
    fontSize: 20,
    fontWeight: FontWeight.Medium,
    opacity: 0.87
  },
  titleNormal: {
    fontSize: 16,
    fontWeight: FontWeight.Medium,
    opacity: 0.87
  },
  titleSmall: {
    fontSize: 14,
    fontWeight: FontWeight.Medium,
    opacity: 0.87
  },
  bodyNormal: {
    fontSize: 14,
    fontWeight: FontWeight.Regular,
    opacity: 0.6
  },
  bodySmall: {
    fontSize: 12,
    fontWeight: FontWeight.Regular,
    opacity: 0.6
  },
  caption: {
    fontSize: 12,
    fontWeight: FontWeight.Regular,
    opacity: 0.38
  }
};

// 定义动画配置接口
interface AnimationConfig {
  duration: number;
  curve: Curve;
  delay: number;
  iterations: number;
  playMode: PlayMode;
}

// 定义 Animations 接口
interface AnimationsInterface {
  durationFast: number;
  durationNormal: number;
  durationSlow: number;
  curveDefault: Curve;
  fadeIn: AnimationConfig;
  scaleNormal: AnimationConfig;
}

// 动画
export const Animations: AnimationsInterface = {
  // 持续时间
  durationFast: 150,
  durationNormal: 250,
  durationSlow: 350,
  curveDefault: Curve.EaseInOut,
  fadeIn: {
    duration: 250,
    curve: Curve.EaseInOut,
    delay: 0,
    iterations: 1,
    playMode: PlayMode.Normal
  },
  scaleNormal: {
    duration: 150,
    curve: Curve.EaseInOut,
    delay: 0,
    iterations: 1,
    playMode: PlayMode.Normal
  }
};
