export class CreateTaskDto {
  taskType: string;
  projectId: string;
  payload: Record<string, any>;
}
