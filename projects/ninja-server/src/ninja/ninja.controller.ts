import assert from 'assert';
import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { NinjaService } from './ninja.service.js';
import { ApiEndpoint, ApiEndpointMethods } from '@meepen/poe-accountant-api';
import { PriceItemRequestDto } from '../dto/price-item-request.dto.js';
import { PriceItemResponseDto } from '../dto/price-item-response.dto.js';
import { PriceTabRequestDto } from '../dto/price-tab-request.dto.js';
import { PriceTabResponseDto } from '../dto/price-tab-response.dto.js';
import { PriceItemResultResponseDto } from '../dto/price-item-result-response.dto.js';
import { PriceItemResultRequestDto } from '../dto/price-item-result-request.dto.js';
import { PriceTabResultRequestDto } from '../dto/price-tab-result-request.dto.js';
import { PriceTabResultResponseDto } from '../dto/price-tab-result-response.dto.js';

assert(
  ApiEndpointMethods[ApiEndpoint.PriceItemRequest] === 'POST',
  'PriceItemRequest must be a POST request',
);
assert(
  ApiEndpointMethods[ApiEndpoint.PriceTabRequest] === 'POST',
  'PriceTabRequest must be a POST request',
);

assert(
  ApiEndpointMethods[ApiEndpoint.PriceItemResult] === 'GET',
  'PriceItemResult must be a GET request',
);
assert(
  ApiEndpointMethods[ApiEndpoint.PriceTabResult] === 'GET',
  'PriceTabResult must be a GET request',
);

@Controller('ninja')
export class NinjaController {
  constructor(private readonly ninjaService: NinjaService) {}

  @Post(ApiEndpoint.PriceItemRequest)
  requestItemPrice(
    @Body() body: PriceItemRequestDto,
  ): Promise<PriceItemResponseDto> {
    return this.ninjaService.getItemPrice(body);
  }
  @Post(ApiEndpoint.PriceTabRequest)
  requestTabPrice(
    @Body() body: PriceTabRequestDto,
  ): Promise<PriceTabResponseDto> {
    return this.ninjaService.getTabPrice(body);
  }

  @Get(ApiEndpoint.PriceItemResult)
  getItemPriceResult(
    @Query() request: PriceItemResultRequestDto,
  ): Promise<PriceItemResultResponseDto> {
    return this.ninjaService.getItemPriceResult(request);
  }
  @Get(ApiEndpoint.PriceTabResult)
  getTabPriceResult(
    @Query() request: PriceTabResultRequestDto,
  ): Promise<PriceTabResultResponseDto> {
    return this.ninjaService.getTabPriceResult(request);
  }
}
