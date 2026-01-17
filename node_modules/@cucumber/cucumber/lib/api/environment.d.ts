import { ILogger } from '../logger';
import { IRunEnvironment } from './types';
type EnvironmentWithLogger = Required<IRunEnvironment> & {
    logger: ILogger;
};
export declare function mergeEnvironment(provided: IRunEnvironment): EnvironmentWithLogger;
export {};
