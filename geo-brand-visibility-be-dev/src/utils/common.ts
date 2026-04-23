import { PaginationResult } from 'src/shared/dtos/pagination-result.dto';

export const createPaginatedResponse = <T, R>(
  data: T[] | undefined,
  total: number,
  params: { page?: number; limit?: number },
  mapper: (item: T) => R,
): PaginationResult<R> => {
  const flattenedData: R[] = data?.map(mapper) || [];

  return new PaginationResult(
    flattenedData,
    total,
    params.page ?? 1,
    params.limit ?? 10,
  );
};
