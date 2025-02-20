export class Accumulator {
  private count: number = 0;

  public increment(value: number = 1) {
    this.count += value;
  }

  public get value(): number {
    return this.count;
  }
} 