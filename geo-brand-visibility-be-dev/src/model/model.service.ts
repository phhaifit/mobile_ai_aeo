import { Injectable, Logger } from '@nestjs/common';
import { ModelRepository } from './model.repository';
import { ModelDto } from './dto/model.dto';

@Injectable()
export class ModelService {
  private readonly logger = new Logger(ModelService.name);

  constructor(private readonly modelRepository: ModelRepository) {}

  async getAllModels(): Promise<ModelDto[]> {
    return this.modelRepository.findAll();
  }
}
