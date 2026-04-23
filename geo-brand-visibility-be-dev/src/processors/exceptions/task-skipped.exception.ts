export class TaskSkippedException extends Error {
  constructor(reason: string) {
    super(reason);
    this.name = 'TaskSkippedException';
  }
}
