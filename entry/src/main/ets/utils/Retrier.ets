export class Retrier {
  public static async tryAsyncWithFix<E>(
    tryFunction: () => Promise<E>,
    catchFunction: (error: Error) => Promise<void>,
    retryTimes: number,
    isFatalError?: (error: Error) => boolean
  ): Promise<E> {
    let attempts = 0;
    while (attempts < retryTimes) {
      try {
        return await tryFunction();
      } catch (error) {
        if (error instanceof Error) {
          if (isFatalError && isFatalError(error)) {
            throw error;
          }
          await catchFunction(error);
        } else {
          throw new Error("Unknown error occurred");
        }
        attempts++;
      }
    }
    throw new Error("Max retry attempts reached");
  }
} 