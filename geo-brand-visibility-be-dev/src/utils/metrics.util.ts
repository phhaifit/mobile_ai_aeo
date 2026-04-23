const BRAND_VISIBILITY_WEIGHT = 0.6;
const LINK_VISIBILITY_WEIGHT = 0.4;

export function calcMentionRate(brandMentions: number, total: number): number {
  if (total === 0) return 0;
  return (brandMentions / total) * 100;
}

export function calcReferenceRate(
  linkReferences: number,
  total: number,
): number {
  if (total === 0) return 0;
  return (linkReferences / total) * 100;
}

export function calcVisibilityScore(
  brandMentions: number,
  linkReferences: number,
  total: number,
): number {
  if (total === 0) return 0;
  const score =
    ((brandMentions / total) * BRAND_VISIBILITY_WEIGHT +
      (linkReferences / total) * LINK_VISIBILITY_WEIGHT) *
    100;
  return Math.round(score * 10) / 10;
}
