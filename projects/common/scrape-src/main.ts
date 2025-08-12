// Scrapes the URL https://www.pathofexile.com/developer/docs/reference#types
// and converts the types to TypeScript interfaces.

// import axios from 'axios';
import { createWriteStream } from 'fs';
import { readFile, writeFile } from 'fs/promises';
import { htmlToData } from './html-to-data.js';
import { ScrapeTypesManager } from './types-manager.js';

const BASE_URL = 'https://www.pathofexile.com/developer/docs/reference#types';
const OUTPUT_FILE = './src/poe.gen.ts';
const outStream = createWriteStream(OUTPUT_FILE);

// const response = (await axios.get(BASE_URL)).data;
const response = await readFile('./docs/docs.htm', 'utf-8');

const allObjects = htmlToData(response);

outStream.write(`// This file is auto-generated from ${BASE_URL}\n\n`);

const typesManager = new ScrapeTypesManager(allObjects);
for (const type of typesManager.generateTypeScriptTypes()) {
  outStream.write(type);
}

const data = await readFile('./docs/stats.json', 'utf-8');
await writeFile(
  './src/trade-stats.gen.ts',
  `import { Type, plainToInstance } from 'class-transformer';
import { IsArray, IsString, ValidateNested, IsInt, IsOptional } from 'class-validator';
import "reflect-metadata";

export class TradeStatsEntryOption {
  @IsInt()
  id!: number;

  @IsString()
  text!: string;
}

export class TradeStatsEntryOptions {
  @Type(() => TradeStatsEntryOption)
  @IsArray()
  @ValidateNested({ each: true })
  options!: TradeStatsEntryOption[];
}

export class TradeStatsEntry {
  @IsString()
  id!: string;

  @IsString()
  text!: string;

  @IsString()
  type!: string;

  @IsOptional()
  option?: TradeStatsEntryOptions;
}

export class TradeStatsGroup {
  @IsString()
  id!: string;

  @IsString()
  label!: string;

  @Type(() => TradeStatsEntry)
  @IsArray()
  @ValidateNested({ each: true })
  entries!: TradeStatsEntry[];
}

export class TradeStats {
  @Type(() => TradeStatsGroup)
  @IsArray()
  @ValidateNested({ each: true })
  result!: TradeStatsGroup[];
}

export const tradeStats = plainToInstance(TradeStats, ${JSON.stringify(JSON.parse(data), null, 2)});
`,
  'utf-8',
);
