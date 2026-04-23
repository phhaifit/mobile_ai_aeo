export function convertPgTimeStampToStrDate(pgTimeStamp: string): string {
  return pgTimeStamp.split('T')[0];
}
