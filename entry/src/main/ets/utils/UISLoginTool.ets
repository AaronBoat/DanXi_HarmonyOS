import HttpService from '../common/service/HttpService';
import { IndependentCookieJar } from '../common/service/IndependentCookieJar';
import { PersonInfo } from '../common/model/PersonInfo';
import Response from '@ohos.net.http';
import { Retrier } from './Retrier';
import { ReadWriteMutex } from './ReadWriteMutex';
import { Accumulator } from './Accumulator';
import { CommonConstants } from '../common/constants/CommonConstants';

export class UISLoginTool {
  static _lockMap: Map<IndependentCookieJar, ReadWriteMutex> = new Map<IndependentCookieJar, ReadWriteMutex>();
  static _epochMap: Map<IndependentCookieJar, Accumulator> = new Map<IndependentCookieJar, Accumulator>();

  static async tryAsyncWithAuth<E>(
    dio: HttpService,
    serviceUrl: string,
    jar: IndependentCookieJar,
    info: PersonInfo | null,
    execute: () => Promise<E>,
    retryTimes: number = 1,
    isFatalError?: (error: Error) => boolean
  ): Promise<E> {
    const lock = UISLoginTool._lockMap.get(jar) || new ReadWriteMutex();
    UISLoginTool._lockMap.set(jar, lock);
    
    const epoch = UISLoginTool._epochMap.get(jar) || new Accumulator();
    UISLoginTool._epochMap.set(jar, epoch);
    
    let currentEpoch: number | null = null;

    return await Retrier.tryAsyncWithFix<E>(
      async () => {
        return await lock.protectRead(async () => {
          currentEpoch = epoch.value;
          if ((await jar.loadForRequest(serviceUrl)).isEmpty) {
            throw new Error("Cannot find cookies for " + serviceUrl);
          }
          return await execute();
        });
      },
      async (error: Error) => {
        await lock.protectWrite(async () => {
          if (currentEpoch !== epoch.value) {
            return null; // Someone has tried to log in before us
          }
          if (isFatalError && isFatalError(error)) {
            throw error;
          }
          await UISLoginTool._loginUIS(dio, serviceUrl, jar, info);
          epoch.increment(1);
        });
      },
      retryTimes,
      isFatalError
    );
  }

  static async loginUIS(
    dio: HttpService,
    serviceUrl: string,
    jar: IndependentCookieJar,
    info: PersonInfo | null
  ): Promise<Response | null> {
    const lock = UISLoginTool._lockMap.putIfAbsent(jar, () => new ReadWriteMutex());
    const epoch = UISLoginTool._epochMap.putIfAbsent(jar, () => new Accumulator());

    return await lock.protectWrite(async () => {
      const result = await UISLoginTool._loginUIS(dio, serviceUrl, jar, info);
      epoch.increment(1);
      return result;
    });
  }

  static async _loginUIS(
    dio: HttpService,
    serviceUrl: string,
    jar: IndependentCookieJar,
    info: PersonInfo | null
  ): Promise<Response | null> {
    const workDio = new HttpService();
    workDio.setOptions({
      receiveDataWhenStatusError: true,
      connectTimeout: 5000,
      receiveTimeout: 5000,
      sendTimeout: 5000
    });

    const workJar = IndependentCookieJar.createFrom(jar);
    workDio.addInterceptor(new CookieManager(workJar));

    // Delete specific cookies if necessary
    workJar.deleteCookiesByName("CASTGC");

    let data: Record<string, string> = {};
    let res = await workDio.get(serviceUrl);
    
    // Parse the response to extract input fields
    const inputs = parseInputs(res.data);
    for (const input of inputs) {
      if (input.type !== "button") {
        data[input.name] = input.value;
      }
    }

    data['username'] = info!.id;
    data['password'] = info.password;

    res = await workDio.post(serviceUrl, data);
    
    if (res.data.includes(CommonConstants.CREDENTIALS_INVALID)) {
      throw new CredentialsInvalidException();
    } else if (res.data.includes(CommonConstants.CAPTCHA_CODE_NEEDED)) {
      throw new CaptchaNeededException();
    } else if (res.data.includes(CommonConstants.UNDER_MAINTENANCE)) {
      throw new NetworkMaintenanceException();
    } else if (res.data.includes(CommonConstants.WEAK_PASSWORD)) {
      throw new GeneralLoginFailedException();
    }

    jar.cloneFrom(workJar);
    return res;
  }

  static parseInputs(html: string): Array<{ name: string, value: string, type: string }> {
    const inputs: Array<{ name: string, value: string, type: string }> = [];
    // 解析 HTML 逻辑，提取输入字段
    // 这里可以使用正则表达式或其他解析方法
    return inputs;
  }
}

class CaptchaNeededException extends Error {}
class CredentialsInvalidException extends Error {}
class NetworkMaintenanceException extends Error {}
class GeneralLoginFailedException extends Error {} 