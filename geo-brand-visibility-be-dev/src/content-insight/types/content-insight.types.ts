import type { Database } from '../../supabase/supabase.types';
import { InsightGroup as InsightGroupEnum } from '../enum/insight-group.enum';
import { InsightType as InsightTypeEnum } from '../enum/insight-type.enum';

export const INSIGHT_GROUP_VALUES = Object.values(InsightGroupEnum);
export const INSIGHT_TYPE_VALUES = Object.values(InsightTypeEnum);

export type InsightGroup = Database['public']['Enums']['InsightGroup'];
export type InsightType = Database['public']['Enums']['InsightType'];

export { InsightGroupEnum, InsightTypeEnum };
