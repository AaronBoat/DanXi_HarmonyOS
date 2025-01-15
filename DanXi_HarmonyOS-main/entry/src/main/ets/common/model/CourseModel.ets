/**
 * Course model class
 */

import { CourseTime } from './CourseTimeModel';

/**
 * Course type enum
 */
export enum CourseType {
  REQUIRED = 'REQUIRED',
  ELECTIVE = 'ELECTIVE',
  OPTIONAL = 'OPTIONAL',
  CUSTOM = 'CUSTOM'
}

export interface CourseJsonPart {
  // 这些类型是推测出来的
  kch: string;
  kcmc: string;
  jsxm: string;
  jxdd?: string;
  zcbh: string,
  xq: number
  ksjcdm: number
  // 您可以根据实际情况添加更多的属性
}

export interface CourseJSON {
  teacherIds: string[],
  teacherNames: string[],
  courseId: string,
  courseName: string,
  roomId: string,
  roomName: string,
  availableWeeks: number[],
  times: CourseTime[],
  courseType: CourseType,
  credits: number,
  description: string,
  semester:string
}
/**
 * Course class
 */
@Observed
export class Course {
  teacherIds: string[] = [];
  teacherNames: string[] = [];
  courseId: string = '';
  courseName: string = '';
  roomId: string = '';
  roomName: string = '';
  availableWeeks: number[] = [];
  times: CourseTime[] = [];
  courseType: CourseType = CourseType.REQUIRED;
  credits: number = 0;
  description: string = '';
  semester: string = "";

  constructor(
    courseId: string,
    courseName: string,
    teacherName: string,
    roomName: string,
    time: string,
    courseType: CourseType = CourseType.REQUIRED,
    credits: number = 0,
    description: string = '',
    semester: string = ""
  ) {
    this.courseId = courseId;
    this.courseName = courseName;
    this.teacherNames = [teacherName];
    this.roomName = roomName;
    this.courseType = courseType;
    this.credits = credits;
    this.description = description;
    this.semester = semester;
  }

  /**
   * Parse weeks string to available weeks array
   * @param weekStr Week string in binary format (e.g. "101" means week 1 and 3 are available)
   * @returns Array of available weeks
   */
  static parseWeeksFromString(weekStr: string): number[] {
    const availableWeeks: number[] = [];
    for (let i = 0; i < weekStr.length; i++) {
      if (weekStr[i] === '1') {
        availableWeeks.push(i);
      }
    }
    return availableWeeks;
  }

  /**
   * Parse course time from string
   * @param timeStr Time string (e.g. "1*unitCount+1" means Monday first lesson)
   * @returns Array of course times
   */
  static parseTimeFromString(timeStr: string): CourseTime[] {
    const times: CourseTime[] = [];
    const timePattern = /([0-9]+)\*unitCount\+([0-9]+)/g;
    let match: RegExpExecArray | null;
    while ((match = timePattern.exec(timeStr)) !== null) {
      const weekDay = parseInt(match[1]);
      const slot = parseInt(match[2]);
      times.push(new CourseTime(weekDay, slot));
    }
    return times;
  }

  /**
   * Create course from HTML part (for undergraduate)
   * @param htmlPart HTML part containing course info
   * @returns Course object
   */
  static fromHtmlPart(htmlPart: string): Course {
    const infoPattern = /TaskActivity\("([^"]+)","([^"]+)","([^"]+)","([^"]+)","([^"]+)","([^"]+)","([^"]+)"/;
    const timePattern = /[0-9]+\*unitCount\+[0-9]+/g;
    const match = infoPattern.exec(htmlPart);
    
    if (!match) {
      throw new Error('Invalid HTML part');
    }

    const teacherIds:string = match[1]
    const teacherNames:string = match[2]
    const courseId:string = match[3]
    const courseName:string = match[4]
    const roomId:string = match[5]
    const roomName:string = match[6]
    const weeks:string = match[7]

    const course = new Course(courseId, courseName, teacherNames, roomName, '');
    
    course.teacherIds = teacherIds.split(',');
    course.teacherNames = teacherNames.split(',');
    course.roomId = roomId;
    course.availableWeeks = Course.parseWeeksFromString(weeks);
    
    // Parse course times
    const timeMatches = htmlPart.match(timePattern);
    if (timeMatches) {
      course.times = Course.parseTimeFromString(timeMatches.join(' '));
    }

    return course;
  }

  /**
   * Create course from JSON part (for postgraduate)
   * @param jsonPart JSON object containing course info
   * @returns Course object
   */
  static fromPGPart(jsonPart: CourseJsonPart): Course {
    const course = new Course(
      jsonPart.kch,
      jsonPart.kcmc,
      jsonPart.jsxm,
      jsonPart.jxdd || ' ',
      ''
    );

    // Add a prefix zero to work with parseWeeksFromString
    course.availableWeeks = Course.parseWeeksFromString('0' + jsonPart.zcbh);
    course.times = [new CourseTime(jsonPart.xq - 1, jsonPart.ksjcdm - 1)];

    return course;
  }

  /**
   * Convert course to JSON object
   * @returns JSON object
   */
  toJSON(): CourseJSON {
    return {
      teacherIds: this.teacherIds,
      teacherNames: this.teacherNames,
      courseId: this.courseId,
      courseName: this.courseName,
      roomId: this.roomId,
      roomName: this.roomName,
      availableWeeks: this.availableWeeks,
      times: this.times,
      courseType: this.courseType,
      credits: this.credits,
      description: this.description,
      semester: this.semester
    };
  }
}
