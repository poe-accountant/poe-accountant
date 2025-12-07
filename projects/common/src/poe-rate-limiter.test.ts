import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';

import {
  PoeRateLimiter,
  LocalRuleManager,
  PoeRateLimiterOptions,
} from './poe-rate-limiter.js';
import { serverApiPaths } from './poe.gen.js';

describe('LocalRuleManager', () => {
  let ruleManager: LocalRuleManager;
  const options: PoeRateLimiterOptions = {
    additionalDelayMs: 100,
    extraRuleThreshold: 10,
  };

  beforeEach(() => {
    ruleManager = new LocalRuleManager(options);
  });

  it('should return the same rule instance for the same name', () => {
    const rule1 = ruleManager.getRule('test-rule');
    const rule2 = ruleManager.getRule('test-rule');
    expect(rule1).toBe(rule2);
  });

  it('should return different rule instances for different names', () => {
    const rule1 = ruleManager.getRule('rule-one');
    const rule2 = ruleManager.getRule('rule-two');
    expect(rule1).not.toBe(rule2);
  });

  it('should return the same policy instance for the same name', () => {
    const policy1 = ruleManager.getPolicy('test-policy');
    const policy2 = ruleManager.getPolicy('test-policy');
    expect(policy1).toBe(policy2);
  });

  it('should return different policy instances for different names', () => {
    const policy1 = ruleManager.getPolicy('policy-one');
    const policy2 = ruleManager.getPolicy('policy-two');
    expect(policy1).not.toBe(policy2);
  });
});

describe('PoeRateLimiter', () => {
  let rateLimiter: PoeRateLimiter<any, any>;
  const options: Partial<PoeRateLimiterOptions> = {
    additionalDelayMs: 200,
  };
  const headers = {
    'x-rate-limit-policy': 'policy',
    'x-rate-limit-rules': 'rule1,ip,account',
    // max hits, rule period (seconds), ban period (seconds)
    'x-rate-limit-rule1': '100:60:120',
    // current hits, rule period (seconds), current ban period (seconds)
    'x-rate-limit-rule1-state': '80:60:0',
    'x-rate-limit-ip': '200:60:120',
    'x-rate-limit-ip-state': '150:60:0',
    'x-rate-limit-account': '300:60:120',
    'x-rate-limit-account-state': '250:60:0',
  };

  const currentDate = new Date(1000000);

  beforeEach(() => {
    rateLimiter = new PoeRateLimiter(options, LocalRuleManager);
    // Mock Date to return a fixed current date
    vi.useFakeTimers();
    vi.setSystemTime(currentDate);
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('should create a manager instance', () => {
    expect(rateLimiter).toBeInstanceOf(PoeRateLimiter);
  });

  it('should use provided options', () => {
    expect(rateLimiter['options'].additionalDelayMs).toBe(200);
    expect(rateLimiter['options'].extraRuleThreshold).toBe(5); // default value
  });

  it('should update limiter with headers', async () => {
    await rateLimiter.updateLimiter(serverApiPaths['Get Character'], headers);
    const nextAvailableTime = await rateLimiter.getNextAvailableTime(
      serverApiPaths['Get Character'],
    );

    expect(nextAvailableTime).toBeInstanceOf(Date);
    // the defaults should result in a next available time that is now or earlier, since we're under the limits
    expect(nextAvailableTime.getTime()).toEqual(currentDate.getTime());
  });

  it('should handle bans correctly', async () => {
    const ban = {
      ...headers,
      'x-rate-limit-rule1-state': '100:60:30', // at max hits, with a ban period of 30 seconds
    };
    await rateLimiter.updateLimiter(serverApiPaths['Get Character'], ban);
    const nextAvailableTime = await rateLimiter.getNextAvailableTime(
      serverApiPaths['Get Character'],
    );

    expect(nextAvailableTime).toBeInstanceOf(Date);
    // next available time should be at least 30 seconds in the future
    expect(nextAvailableTime.getTime()).toEqual(
      currentDate.getTime() + 30000 + options.additionalDelayMs!,
    );
  });

  it('should handle exceeding extra rule threshold with options', async () => {
    const excessive = {
      ...headers,
      'x-rate-limit-rule1-state': '99:60:0', // just under max hits
    };
    await rateLimiter.updateLimiter(serverApiPaths['Get Character'], excessive);
    const nextAvailableTime = await rateLimiter.getNextAvailableTime(
      serverApiPaths['Get Character'],
    );

    // the next available time should be the first thing in the queue (now) + the period + extra delay
    expect(nextAvailableTime.getTime()).toEqual(
      currentDate.getTime() + 60000 + options.additionalDelayMs!,
    );
  });
});
