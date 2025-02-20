export class ReadWriteMutex {
  private readers: number = 0;
  private writer: boolean = false;
  private waitingWriters: number = 0;

  public async protectRead<T>(fn: () => Promise<T>): Promise<T> {
    while (this.writer || this.waitingWriters > 0) {
      await this.delay();
    }
    this.readers++;
    try {
      return await fn();
    } finally {
      this.readers--;
    }
  }

  public async protectWrite<T>(fn: () => Promise<T>): Promise<T> {
    this.waitingWriters++;
    while (this.readers > 0 || this.writer) {
      await this.delay();
    }
    this.waitingWriters--;
    this.writer = true;
    try {
      return await fn();
    } finally {
      this.writer = false;
    }
  }

  private delay(): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, 10));
  }
} 