import { Type } from 'class-transformer';
import { IsBoolean, ValidateIf } from 'class-validator';
import { Price } from './price.dto.js';

export class PriceItemResultResponse {
  @IsBoolean()
  completed!: boolean;

  @ValidateIf((o) => o.completed)
  @Type(() => Price)
  price?: Price;
}
