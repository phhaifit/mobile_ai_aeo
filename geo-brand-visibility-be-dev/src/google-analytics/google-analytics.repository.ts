import { Inject, Injectable } from '@nestjs/common';
import { SUPABASE } from '../utils/const';
import { SupabaseClient } from '@supabase/supabase-js';
import { Database } from '../supabase/supabase.types';
import { mapSqlError } from '../utils/map-sql-error.util';
import { GoogleOAuthCredential } from '../google-search-console/google-search-console.repository';

const CREDENTIAL_TABLE = 'GoogleOAuthCredential';
const PROPERTY_TABLE = 'GaProperty';

export interface GaProperty {
  id: string;
  projectId: string;
  userId: string;
  propertyId: string;
  displayName: string | null;
  createdAt: string;
  updatedAt: string;
}

@Injectable()
export class GaRepository {
  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  // ── GoogleOAuthCredential (shared with GSC) ──

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
        {
          userId,
          projectId,
          encryptedRefreshToken,
          scopes,
          isValid: true,
        },
        { onConflict: 'projectId' },
      )
      .select()
      .single();

    if (error) throw mapSqlError(error);
    return data;
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

  async setCredentialInvalid(projectId: string): Promise<void> {
    const { error } = await (this.supabase as any)
      .from(CREDENTIAL_TABLE)
      .update({ isValid: false })
      .eq('projectId', projectId);

    if (error) throw mapSqlError(error);
  }

  // ── GaProperty ──

  async findPropertyByProjectId(projectId: string): Promise<GaProperty | null> {
    const { data, error } = await (this.supabase as any)
      .from(PROPERTY_TABLE)
      .select('*')
      .eq('projectId', projectId)
      .maybeSingle();

    if (error) throw mapSqlError(error);
    return data;
  }

  async findPropertiesByUserId(userId: string): Promise<GaProperty[]> {
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
    propertyId: string,
    displayName: string | null,
  ): Promise<GaProperty> {
    const { data, error } = await (this.supabase as any)
      .from(PROPERTY_TABLE)
      .insert({ projectId, userId, propertyId, displayName })
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
