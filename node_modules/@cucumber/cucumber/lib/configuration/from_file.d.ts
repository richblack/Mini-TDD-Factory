import { ILogger } from '../logger';
import { IConfiguration } from './types';
export declare function fromFile(logger: ILogger, cwd: string, file: string, profiles?: string[]): Promise<Partial<IConfiguration>>;
