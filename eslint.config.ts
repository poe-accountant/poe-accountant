import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';
import { readdir, readFile } from 'node:fs/promises';
import { join } from 'node:path';
import ts from 'typescript';
import eslintConfigPrettier from 'eslint-config-prettier';
import eslintPluginPrettier from 'eslint-plugin-prettier/recommended';

// Find all workspace paths from subprojects specified in root package.json
const pkg = JSON.parse(
  await readFile(new URL('./package.json', import.meta.url), 'utf8'),
);
const workspaceGlobs: string[] = pkg.workspaces ?? [];
const workspacePaths: string[] = [];

for (const glob of workspaceGlobs) {
  if (glob.endsWith('/*')) {
    const dir = glob.slice(0, -2);
    const entries = await readdir(new URL(`./${dir}`, import.meta.url), {
      withFileTypes: true,
    });
    for (const entry of entries) {
      if (entry.isDirectory()) {
        workspacePaths.push(join(dir, entry.name));
      }
    }
  } else {
    workspacePaths.push(glob);
  }
}

async function collectInfoForWorkspace(workspaceDir: string) {
  const tsconfigPath = join(workspaceDir, 'tsconfig.json');
  const parsed = ts.readConfigFile(tsconfigPath, ts.sys.readFile);
  if (parsed.error) {
    throw new Error(
      `Failed to read tsconfig at ${tsconfigPath}: ${parsed.error.messageText}`,
    );
  }
  const config = ts.parseJsonConfigFileContent(
    parsed.config,
    ts.sys,
    workspaceDir,
  );

  return {
    tsconfigPath,
    files: config.fileNames,
  };
}

export default tseslint.config(
  eslint.configs.recommended,
  tseslint.configs.recommended,
  {
    ignores: ['**/dist/**/*'],
  },
  eslintPluginPrettier,
  {
    ignores: ['**/*.gen.ts'],
  },
  eslintConfigPrettier,
  {
    files: ['**/*.test.ts'],
    rules: {
      '@typescript-eslint/no-explicit-any': 'off',
    },
  },
  {
    rules: {
      '@typescript-eslint/no-unused-vars': [
        'error',
        {
          argsIgnorePattern: '^_',
          varsIgnorePattern: '^_',
          caughtErrorsIgnorePattern: '^_',
        },
      ],
      'prettier/prettier': [
        'error',
        {
          singleQuote: true,
          trailingComma: 'all',
        },
      ],
    },
  },
  ...(await Promise.all(
    workspacePaths.map(async (workspace) => {
      const { tsconfigPath, files } = await collectInfoForWorkspace(workspace);

      return {
        files,
        basePath: workspace,
        languageOptions: {
          parser: tseslint.parser,
          parserOptions: {
            project: tsconfigPath,
            tsconfigRootdir: workspace,
          },
        },
      };
    }),
  )),
);
