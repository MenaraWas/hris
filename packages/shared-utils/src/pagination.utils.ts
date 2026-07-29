export interface PaginationQuery {
    page? : number, 
    limit? : number
}

export interface PaginationMeta { 
    total : number, 
    page: number, 
    limit: number, 
    totalPages: number
}

export function getPaginationParams (query:PaginationQuery): {skip:number; take:number} {
    const page = Math.max(1, query.page || 1);
     const limit = Math.min(100, query.limit || 10);
  return {
    skip: (page - 1) * limit,
    take: limit,
  };
}

export function buildPaginationMeta(total: number, page: number, limit: number): PaginationMeta {
  return {
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
  };
}