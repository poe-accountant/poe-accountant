import { ClassProvider } from '@nestjs/common';
import { NinjaService } from './ninja.service.js';
import { vi } from 'vitest';

export class NinjaServiceMockImpl implements NinjaService {
  public getItemPrice = vi.fn();
  public getTabPrice = vi.fn();
  public getItemPriceResult = vi.fn();
  public getTabPriceResult = vi.fn();
}

export const NinjaServiceMock: ClassProvider<NinjaService> = {
  provide: NinjaService,
  useClass: NinjaServiceMockImpl,
};
