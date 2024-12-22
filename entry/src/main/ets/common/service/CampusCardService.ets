import HttpService from './HttpService';
import { AuthService } from './AuthService';
import { ResponseResult } from '../model/ResponseResult'

export interface CampusCardRecord {
  time: string;
  location: string;
  amount: number;
  balance: number;
}

export class CampusCardService {
  private static instance: CampusCardService;
  private httpService: HttpService;
  private authService: AuthService;

  private constructor() {
    this.httpService = HttpService.getInstance();
    this.authService = AuthService.getInstance();
  }

  public static getInstance(): CampusCardService {
    if (!CampusCardService.instance) {
      CampusCardService.instance = new CampusCardService();
    }
    return CampusCardService.instance;
  }

  public async getBalance(): Promise<number> {
    try {
      const token = await this.authService.getCurrentUsername();
      let data: Record<string, Object> = {
        'Authorization': token
      }
      const response: ResponseResult<string> = await this.httpService.get('https://your-campus-card-server.com/balance', data);
      return parseFloat(response.data ?? "");
    } catch (error) {
      console.error('Get balance failed:', error);
      return 0;
    }
  }

  public async getConsumptionRecords(days: number = 30): Promise<CampusCardRecord[]> {
    try {
      const token = await this.authService.getCurrentUsername();
      let data: Record<string, Object> = {
        'Authorization': token
      }
      const response: ResponseResult<string> = await this.httpService.get(`https://your-campus-card-server.com/records?days=${days}`, data);
      return JSON.parse(response.data ?? "") as CampusCardRecord[];
    } catch (error) {
      console.error('Get consumption records failed:', error);
      return [];
    }
  }
}
