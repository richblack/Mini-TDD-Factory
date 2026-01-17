/// <reference types="node" />
import { EventEmitter } from 'node:events';
import { IdGenerator } from '@cucumber/messages';
import { IRuntime } from '../runtime';
import { EventDataCollector } from '../formatter/helpers';
import { SupportCodeLibrary } from '../support_code_library_builder/types';
import { ILogger } from '../logger';
import { IRunOptionsRuntime } from './types';
export declare function makeRuntime({ cwd, logger, eventBroadcaster, eventDataCollector, pickleIds, newId, supportCodeLibrary, options: { parallel, ...options }, }: {
    cwd: string;
    logger: ILogger;
    eventBroadcaster: EventEmitter;
    eventDataCollector: EventDataCollector;
    newId: IdGenerator.NewId;
    pickleIds: string[];
    supportCodeLibrary: SupportCodeLibrary;
    options: IRunOptionsRuntime;
}): IRuntime;
