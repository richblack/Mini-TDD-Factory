import { ILogger } from '../logger';
import { ISourcesCoordinates, ISupportCodeCoordinates } from '../api';
import { IResolvedPaths } from './types';
export declare function resolvePaths(logger: ILogger, cwd: string, sources: Pick<ISourcesCoordinates, 'paths'>, support?: ISupportCodeCoordinates): Promise<IResolvedPaths>;
