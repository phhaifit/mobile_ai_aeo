import type { LoggerService } from '@nestjs/common';
import { WinstonModule, type WinstonModuleOptions } from 'nest-winston';
import * as winston from 'winston';
import { isProduction } from '../../utils/environment.util';

interface LogMeta {
  timestamp: string;
  level: string;
  message: string;
  context?: string;
  ms?: string;
}

/** Visual prefix icon per log level (plain name, before colourisation). */
const LEVEL_ICONS: Record<string, string> = {
  error: '✖',
  warn: '⚠',
  info: '✔',
  debug: '◈',
  verbose: '…',
};

/**
 * Register vivid terminal colours for each log level.
 * These are applied by `format.colorize({ all: true })`.
 */
winston.addColors({
  error: 'bold red',
  warn: 'bold yellow',
  info: 'bold green',
  debug: 'bold cyan',
  verbose: 'dim white',
});

/** Strip ANSI escape codes so we can look up icons by plain level name. */
function stripAnsi(str: string): string {
  const pattern = [
    '[\\u001B\\u009B][[\\]()#;?]*(?:(?:(?:(?:;[-a-zA-Z\\d\\/#&.:=?%@~%]*)+|[a-zA-Z\\d\\/#&.:=?%@~%]*);\\d+)|',
    '(?:(?:\\d+(?:;\\d+)*)?\\db|\\d{1,4}(?:;\\d+)*[\\dA-PR-TZcf-ntqry=><~]))',
  ].join('');

  return str.replace(new RegExp(pattern, 'g'), '');
}

/** Build the single Console transport with our colourful format. */
function buildFormat(): winston.Logform.Format {
  return winston.format.combine(
    winston.format.timestamp({ format: 'HH:mm:ss' }),
    winston.format.ms(),
    winston.format.printf((raw) => {
      const info = raw as unknown as LogMeta;
      const level = stripAnsi(info.level).toLowerCase();
      const icon = LEVEL_ICONS[level] ?? '·';
      const ctx = info.context ?? 'Nest';
      const time = `\x1b[90m${info.timestamp}\x1b[0m`;
      const ms = info.ms ? ` \x1b[90m${info.ms}\x1b[0m` : '';

      // Define level-specific styling
      let levelStyle = '';
      switch (level) {
        case 'error':
          levelStyle = '\x1b[97m\x1b[41m  ERROR  \x1b[0m'; // White on Red
          break;
        case 'warn':
          levelStyle = '\x1b[30m\x1b[43m  WARN   \x1b[0m'; // Black on Yellow
          break;
        case 'info':
          levelStyle = '\x1b[30m\x1b[42m  INFO   \x1b[0m'; // Black on Green
          break;
        case 'debug':
          levelStyle = '\x1b[30m\x1b[46m  DEBUG  \x1b[0m'; // Black on Cyan
          break;
        default:
          levelStyle = `\x1b[30m\x1b[47m  ${level.toUpperCase().padEnd(5)}  \x1b[0m`;
      }

      const messageStyle =
        level === 'error' ? '\x1b[31m' : level === 'warn' ? '\x1b[33m' : '';
      const reset = '\x1b[0m';

      return `${time} ${levelStyle} ${icon} \x1b[35m[${ctx}]\x1b[0m ${messageStyle}${info.message}${reset}${ms}`;
    }),
  );
}

export function createAppLogger(): LoggerService {
  const options: WinstonModuleOptions = {
    transports: [
      new winston.transports.Console({
        format: buildFormat(),
        level: isProduction() ? 'info' : 'debug',
      }),
    ],
  };

  const nestWinston = WinstonModule as unknown as {
    createLogger: (options: WinstonModuleOptions) => LoggerService;
  };

  return nestWinston.createLogger(options);
}
