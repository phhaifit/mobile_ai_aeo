import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import * as qs from 'qs';

@Injectable()
export class QueryParserMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    const urlParts = req.originalUrl.split('?');
    const queryString = urlParts.length > 1 ? urlParts[1] : null;

    if (queryString) {
      const nestedQuery = qs.parse(queryString);

      Object.defineProperty(req, 'query', {
        value: nestedQuery,
        writable: true,
        enumerable: true,
        configurable: true,
      });
    }
    next();
  }
}
