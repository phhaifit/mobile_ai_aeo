import { Inject, Injectable } from '@nestjs/common';
import { SUPABASE } from '../utils/const';
import { SupabaseClient } from '@supabase/supabase-js';
import { Database, Tables, TablesInsert } from '../supabase/supabase.types';
import { CreateTaskDto } from './dto/create-task.dto';
import { TASK_STATUS } from '../utils/const';

type Task = Tables<'Task'>;
type TaskInsert = TablesInsert<'Task'>;

@Injectable()
export class TaskRepository {
  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async create(dto: CreateTaskDto): Promise<Task> {
    const insertData: TaskInsert = {
      taskType: dto.taskType,
      projectId: dto.projectId,
      payload: dto.payload as any,
      status: TASK_STATUS.PENDING,
    };

    const { data, error } = await this.supabase
      .from('Task')
      .insert(insertData)
      .select()
      .single();

    if (error) {
      throw new Error(`Failed to create task: ${error.message}`);
    }

    return data;
  }

  async updateStatus(
    taskId: string,
    status: string,
    result?: Record<string, any>,
  ): Promise<void> {
    const updateData: any = { status };

    if (status === TASK_STATUS.RUNNING) {
      updateData.startedAt = new Date().toISOString();
    }

    if (
      status === TASK_STATUS.DONE ||
      status === TASK_STATUS.FAILED ||
      status === TASK_STATUS.PARTIAL
    ) {
      updateData.finishedAt = new Date().toISOString();
    }

    if (result) {
      updateData.result = result;
    }

    const { error } = await this.supabase
      .from('Task')
      .update(updateData)
      .eq('id', taskId);

    if (error) {
      throw new Error(`Failed to update task status: ${error.message}`);
    }
  }

  async findById(taskId: string): Promise<Task | null> {
    const { data, error } = await this.supabase
      .from('Task')
      .select('*')
      .eq('id', taskId)
      .single();

    if (error) {
      return null;
    }

    return data;
  }
}
