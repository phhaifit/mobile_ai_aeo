import { Inject, Injectable } from '@nestjs/common';
import { SUPABASE } from '../utils/const';
import { SupabaseClient } from '@supabase/supabase-js';
import { Database } from '../supabase/supabase.types';
import { mapSqlError } from '../utils/map-sql-error.util';

const CREDENTIAL_TABLE = 'GoogleOAuthCredential';
const PROPERTY_TABLE = 'GscProperty';

export interface GoogleOAuthCredential {
  id: string;
  userId: string;
  projectId: string;
  encryptedRefreshToken: string;
  scopes: string[];
  isValid: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface GscProperty {
  id: string;
  projectId: string;
  userId: string;
  siteUrl: string;
  permissionLevel: string | null;
  createdAt: string;
  updatedAt: string;
}

@Injectable()
export class GscRepository {
  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  // ── GoogleOAuthCredential ──

  async findCredentialByProjectId(
    projectId: string,
  ): Promise<GoogleOAuthCredential | null> {
    const { data, error } = await (this.supabase as any)
      .from(CREDENTIAL_TABLE)
      .select('*')
      .eq('projectId', projectId)
      .maybeSingle();

    if (error) throw mapSqlError(error);
    return data;
  }

  async upsertCredential(
    userId: string,
    projectId: string,
    encryptedRefreshToken: string,
    scopes: string[],
  ): Promise<GoogleOAuthCredential> {
    const { data, error } = await (this.supabase as any)
      .from(CREDENTIAL_TABLE)
      .upsert(
        { userId, projectId, encryptedRefreshToken, scopes, isValid: true },
        { onConflict: 'projectId' },
      )
      .select()
      .single();

    if (error) throw mapSqlError(error);
    return data;
  }

  async setCredentialInvalid(projectId: string): Promise<void> {
    const { error } = await (this.supabase as any)
      .from(CREDENTIAL_TABLE)
      .update({ isValid: false })
      .eq('projectId', projectId);

    if (error) throw mapSqlError(error);
  }

  async removeScopesFromCredential(
    projectId: string,
    scopesToRemove: string[],
  ): Promise<void> {
    const credential = await this.findCredentialByProjectId(projectId);
    if (!credential) return;

    const remainingScopes = credential.scopes.filter(
      (s) => !scopesToRemove.includes(s),
    );

    if (remainingScopes.length === 0) {
      // No scopes left — delete the credential entirely
      const { error } = await (this.supabase as any)
        .from(CREDENTIAL_TABLE)
        .delete()
        .eq('projectId', projectId);
      if (error) throw mapSqlError(error);
    } else {
      const { error } = await (this.supabase as any)
        .from(CREDENTIAL_TABLE)
        .update({ scopes: remainingScopes })
        .eq('projectId', projectId);
      if (error) throw mapSqlError(error);
    }
  }

  async deleteCredential(projectId: string): Promise<void> {
    const { error } = await (this.supabase as any)
      .from(CREDENTIAL_TABLE)
      .delete()
      .eq('projectId', projectId);

    if (error) throw mapSqlError(error);
  }

  // ── GscProperty ──

  async findPropertyByProjectId(
    projectId: string,
  ): Promise<GscProperty | null> {
    const { data, error } = await (this.supabase as any)
      .from(PROPERTY_TABLE)
      .select('*')
      .eq('projectId', projectId)
      .maybeSingle();

    if (error) throw mapSqlError(error);
    return data;
  }

  async findPropertiesByUserId(userId: string): Promise<GscProperty[]> {
    const { data, error } = await (this.supabase as any)
      .from(PROPERTY_TABLE)
      .select('*')
      .eq('userId', userId);

    if (error) throw mapSqlError(error);
    return data || [];
  }

  async createProperty(
    projectId: string,
    userId: string,
    siteUrl: string,
    permissionLevel: string | null,
  ): Promise<GscProperty> {
    const { data, error } = await (this.supabase as any)
      .from(PROPERTY_TABLE)
      .insert({ projectId, userId, siteUrl, permissionLevel })
      .select()
      .single();

    if (error) throw mapSqlError(error);
    return data;
  }

  async deleteProperty(projectId: string): Promise<void> {
    const { error } = await (this.supabase as any)
      .from(PROPERTY_TABLE)
      .delete()
      .eq('projectId', projectId);

    if (error) throw mapSqlError(error);
  }

  async deletePropertiesByUserId(userId: string): Promise<void> {
    const { error } = await (this.supabase as any)
      .from(PROPERTY_TABLE)
      .delete()
      .eq('userId', userId);

    if (error) throw mapSqlError(error);
  }
}
