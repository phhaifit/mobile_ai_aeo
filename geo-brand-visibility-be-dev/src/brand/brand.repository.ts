import { Inject, Injectable, Logger } from '@nestjs/common';
import { SUPABASE } from '../utils/const';
import { SupabaseClient } from '@supabase/supabase-js';
import { Database, Tables, TablesUpdate } from '../supabase/supabase.types';
import { mapSqlError } from '../utils/map-sql-error.util';

const BRAND_TABLE = 'Brand';

type Service = Omit<Tables<'Service'>, 'brandId'>;
type Brand = Omit<Tables<'Brand'>, 'domainConfigMethod'> & {
  services: Service[];
  domainConfigMethod?: 'cname' | 'rewrite' | null;
  logoUrl?: string | null;
  defaultArticleImageUrl?: string | null;
  blogTitle?: string | null;
  blogHotline?: string | null;
  revenueModel?: string | null;
  customerType?: string | null;
};
type BrandUpdate = TablesUpdate<'Brand'> & {
  services?: {
    id?: string;
    name: string;
    description?: string;
  }[];
  domainConfigMethod?: 'cname' | 'rewrite';
  cloudflareHostnameId?: string | null;
  logoUrl?: string | null;
  defaultArticleImageUrl?: string | null;
  blogTitle?: string | null;
  blogHotline?: string | null;
  revenueModel?: string | null;
  customerType?: string | null;
};

@Injectable()
export class BrandRepository {
  private readonly logger = new Logger(BrandRepository.name);

  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async findById(id: string, userId: string): Promise<Brand | null> {
    const { data, error } = await this.supabase
      .from(BRAND_TABLE)
      .select(
        '*, services:Service(id, name, description), project:Project!inner(projectMembers:Project_Member!inner(userId))',
      )
      .eq('id', id)
      .eq('project.projectMembers.userId', userId)
      .maybeSingle();

    if (error) {
      if (error.code === 'PGRST116') return null;
      throw mapSqlError(error);
    }

    if (data) {
      const { project: _, ...brand } = data;
      return brand as Brand;
    }

    return data;
  }

  async findByProjectId(projectId: string): Promise<Brand | null> {
    const { data, error } = await this.supabase
      .from(BRAND_TABLE)
      .select('*, services:Service(id, name, description)')
      .eq('projectId', projectId)
      .maybeSingle();

    if (error) {
      if (error.code === 'PGRST116') return null;
      throw mapSqlError(error);
    }

    return data as Brand | null;
  }

  async updateById(id: string, brand: BrandUpdate): Promise<Brand> {
    const getNullableParam = (key: keyof BrandUpdate): string => {
      const value = brand[key];
      if (value === undefined) return '___NO_UPDATE___';
      return (value as string | null) ?? '';
    };

    const rpcParams = {
      _id: id,
      _name: brand.name,
      _domain: brand.domain,
      _description: brand.description,
      _target_market: brand.targetMarket,
      _industry: brand.industry,
      _mission: brand.mission,
      _services_to_update:
        brand.services !== undefined
          ? brand.services.filter((s) => s.id)
          : null,
      _services_to_insert:
        brand.services !== undefined
          ? brand.services.filter((s) => !s.id)
          : null,
      _custom_domain: getNullableParam('customDomain'),
      _domain_config_method: getNullableParam('domainConfigMethod'),
      _cloudflare_hostname_id: getNullableParam('cloudflareHostnameId'),
      _logo_url: getNullableParam('logoUrl'),
      _default_article_image_url: getNullableParam('defaultArticleImageUrl'),
      _blog_title: getNullableParam('blogTitle'),
      _blog_hotline: getNullableParam('blogHotline'),
      _revenue_models: getNullableParam('revenueModel'),
      _customer_types: getNullableParam('customerType'),
    };

    const { data, error } = await this.supabase.rpc('update_brand', rpcParams);

    if (error) {
      throw mapSqlError(error);
    }

    return data as Brand;
  }

  async findByName(name: string): Promise<Brand | null> {
    const { data, error } = await this.supabase
      .from(BRAND_TABLE)
      .select('*, services:Service(id, name, description)')
      .eq('name', name)
      .maybeSingle();

    if (error) {
      if (error.code === 'PGRST116') return null;
      throw mapSqlError(error);
    }

    return data as Brand | null;
  }

  async findBySlug(slug: string): Promise<Brand | null> {
    const { data, error } = await this.supabase
      .from(BRAND_TABLE)
      .select('*, services:Service(id, name, description)')
      .eq('slug', slug)
      .maybeSingle();

    if (error) {
      if (error.code === 'PGRST116') return null;
      throw mapSqlError(error);
    }

    return data as Brand | null;
  }

  async findByCustomDomain(domain: string): Promise<Brand | null> {
    const { data, error } = await this.supabase
      .from(BRAND_TABLE)
      .select('*, services:Service(id, name, description)')
      .ilike('customDomain', domain)
      .maybeSingle();

    if (error) {
      if (error.code === 'PGRST116') return null;
      throw mapSqlError(error);
    }

    return data as Brand | null;
  }

  async existsByName(name: string): Promise<boolean> {
    const { count, error } = await this.supabase
      .from(BRAND_TABLE)
      .select('id', { count: 'exact', head: true })
      .ilike('name', name);

    if (error) {
      throw mapSqlError(error);
    }

    return (count ?? 0) > 0;
  }

  async findAllNames(): Promise<string[]> {
    const { data, error } = await this.supabase
      .from(BRAND_TABLE)
      .select('name');

    if (error) {
      throw mapSqlError(error);
    }

    return (data || [])
      .map((item) => item.name)
      .filter((name): name is string => name !== null);
  }

  async findAllNamesAndSlugs(): Promise<{ name: string; slug: string }[]> {
    const { data, error } = await this.supabase
      .from(BRAND_TABLE)
      .select(
        'name, slug, project:Project!inner(subscription:ProjectSubscription!inner(status))',
      )
      .eq('project.subscription.status', 'active');

    if (error) {
      throw mapSqlError(error);
    }

    return (data || [])
      .filter((item) => item.name !== null && item.slug !== null)
      .map(({ name, slug }) => ({ name, slug }));
  }

  async findBySlugPro(slug: string): Promise<Brand | null> {
    const { data, error } = await this.supabase
      .from(BRAND_TABLE)
      .select(
        '*, services:Service(id, name, description), project:Project!inner(subscription:ProjectSubscription!inner(status))',
      )
      .eq('slug', slug)
      .eq('project.subscription.status', 'active')
      .maybeSingle();

    if (error) {
      if (error.code === 'PGRST116') return null;
      throw mapSqlError(error);
    }

    if (data) {
      const { project: _, ...brand } = data;
      return brand as Brand;
    }

    return null;
  }
}
