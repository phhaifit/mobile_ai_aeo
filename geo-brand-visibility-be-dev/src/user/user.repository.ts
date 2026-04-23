import { Inject, Injectable } from '@nestjs/common';
import { SUPABASE } from '../utils/const';
import { SupabaseClient } from '@supabase/supabase-js';
import {
  Database,
  Tables,
  TablesInsert,
  TablesUpdate,
} from '../supabase/supabase.types';
import { mapSqlError } from '../utils/map-sql-error.util';

const USER_TABLE = 'User';
type User = Tables<'User'>;
type UserInsert = TablesInsert<'User'>;
type UserUpdate = TablesUpdate<'User'>;

@Injectable()
export class UserRepository {
  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async findById(id: string): Promise<User | null> {
    const { data, error } = await this.supabase
      .from(USER_TABLE)
      .select('*')
      .eq('id', id)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async findByEmail(email: string): Promise<User | null> {
    const { data, error } = await this.supabase
      .from(USER_TABLE)
      .select('*')
      .eq('email', email)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async findByGoogleId(googleId: string): Promise<User | null> {
    const { data, error } = await this.supabase
      .from(USER_TABLE)
      .select('*')
      .eq('googleId', googleId)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async create(user: UserInsert): Promise<User> {
    const { data, error } = await this.supabase
      .from(USER_TABLE)
      .insert(user)
      .select()
      .single();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async updateById(id: string, user: UserUpdate): Promise<User | null> {
    const { data, error } = await this.supabase
      .from(USER_TABLE)
      .update(user)
      .eq('id', id)
      .select()
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }
}
