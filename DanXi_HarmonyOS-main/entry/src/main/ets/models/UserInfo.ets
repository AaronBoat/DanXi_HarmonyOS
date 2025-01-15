export enum UserGroup {
  FUDAN_UNDERGRADUATE_STUDENT = 'FUDAN_UNDERGRADUATE_STUDENT',
  FUDAN_POSTGRADUATE_STUDENT = 'FUDAN_POSTGRADUATE_STUDENT',
  VISITOR = 'VISITOR'
}

export interface UserInfo {
  id: string;
  password: string;
  name: string;
  userGroup: UserGroup;
} 