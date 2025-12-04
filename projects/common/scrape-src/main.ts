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

const htmlData = htmlToData(response);

outStream.write(`// This file is auto-generated from ${BASE_URL}\n\n`);

outStream.write('\n\n// #region Type Information\n');
const typesManager = new ScrapeTypesManager(htmlData.typeDetails);
for (const type of typesManager.generateTypeScriptTypes()) {
  outStream.write(type);
}
outStream.write('\n\n// #endregion Type Information\n\n');

outStream.write('\n\n// #region Endpoint Information\n\n');
outStream.write(
  `export const serverEndpoint = ${JSON.stringify(htmlData.apiEndpoint)};\n`,
);

outStream.write('export const serverApiPaths = {\n');

for (const [categoryName, categoryEndpoints] of Object.entries(
  htmlData.apiCategories,
)) {
  outStream.write(`\n// #region ${categoryName}\n`);

  for (const endpoint of categoryEndpoints.endpoints) {
    outStream.write(`\n// #region ${endpoint.name}
  ${JSON.stringify(endpoint.name)}: {
    name: ${JSON.stringify(endpoint.name)},
    method: ${JSON.stringify(endpoint.method)},
    path: ${JSON.stringify(endpoint.path)},
    responseType: ${ScrapeTypesManager.safeName(endpoint.type.name)},
  },\n`);
    outStream.write(`\n// #endregion ${endpoint.name}\n`);
  }

  outStream.write(`\n// #endregion ${categoryName}\n`);
}

outStream.write('} as const;\n\n// #endregion Endpoint Information\n\n');

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
