import { PluginManager } from '../plugin';
import { ILogger } from '../logger';
import { IRunConfiguration, IRunEnvironment, ISourcesCoordinates } from './types';
export declare function initializeForLoadSources(logger: ILogger, coordinates: ISourcesCoordinates, environment: Required<IRunEnvironment>): Promise<PluginManager>;
export declare function initializeForLoadSupport(): Promise<PluginManager>;
export declare function initializeForRunCucumber(logger: ILogger, configuration: IRunConfiguration, environment: Required<IRunEnvironment>): Promise<PluginManager>;
