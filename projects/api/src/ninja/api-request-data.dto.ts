import { ApiEndpoint } from './api-endpoints.enum.js';
import { PriceItemRequest } from './price-item-request.dto.js';
import { PriceItemResponse } from './price-item-response.dto.js';
import { PriceItemResultRequest } from './price-item-result-request.dto.js';
import { PriceItemResultResponse } from './price-item-result-response.dto.js';
import { PriceTabRequest } from './price-tab-request.dto.js';
import { PriceTabResponse } from './price-tab-response.dto.js';
import { PriceTabResultRequest } from './price-tab-result-request.dto.js';
import { PriceTabResultResponse } from './price-tab-result-response.dto.js';

export type ApiResultResponseData<T extends ApiEndpoint> =
  T extends ApiEndpoint.PriceItemRequest
    ? [PriceItemRequest, PriceItemResponse]
    : T extends ApiEndpoint.PriceTabRequest
      ? [PriceTabRequest, PriceTabResponse]
      : T extends ApiEndpoint.PriceItemResult
        ? [PriceItemResultRequest, PriceItemResultResponse]
        : T extends ApiEndpoint.PriceTabResult
          ? [PriceTabResultRequest, PriceTabResultResponse]
          : never;

export type ApiRequest<T extends ApiEndpoint> = ApiResultResponseData<T>[0];

export type ApiResponse<T extends ApiEndpoint> = ApiResultResponseData<T>[1];
