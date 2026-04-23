import { Injectable, NotFoundException } from '@nestjs/common';
import { CompetitorRepository } from './competitor.repository';
import { Tables, TablesInsert, TablesUpdate } from '../supabase/supabase.types';

type Competitor = Tables<'Competitor'>;
type CompetitorInsert = TablesInsert<'Competitor'>;
type CompetitorUpdate = TablesUpdate<'Competitor'>;

@Injectable()
export class CompetitorService {
  constructor(private readonly competitorRepository: CompetitorRepository) {}
  async findCompetitorById(id: string): Promise<Competitor> {
    const competitor = await this.competitorRepository.findById(id);

    if (!competitor) {
      throw new NotFoundException('Competitor not found');
    }

    return competitor;
  }

  async findCompetitorsByBrandId(brandId: string): Promise<Competitor[]> {
    return this.competitorRepository.findByBrandId(brandId);
  }

  async createCompetitor(competitor: CompetitorInsert): Promise<Competitor> {
    return this.competitorRepository.create(competitor);
  }

  async updateCompetitor(
    id: string,
    competitor: CompetitorUpdate,
  ): Promise<Competitor> {
    const updatedCompetitor = await this.competitorRepository.updateById(
      id,
      competitor,
    );

    if (!updatedCompetitor) {
      throw new NotFoundException('Competitor not found');
    }

    return updatedCompetitor;
  }

  async deleteCompetitor(id: string): Promise<void> {
    const competitor = await this.competitorRepository.findById(id);

    if (!competitor) {
      throw new NotFoundException('Competitor not found');
    }

    await this.competitorRepository.deleteById(id);
  }
}
