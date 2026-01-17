/// <reference types="node" />
import { EventEmitter } from 'node:events';
import * as messages from '@cucumber/messages';
import { IdGenerator } from '@cucumber/messages';
import { JsonObject } from 'type-fest';
import { EventDataCollector } from '../formatter/helpers';
import { SupportCodeLibrary } from '../support_code_library_builder/types';
export interface IRuntime {
    start: () => Promise<boolean>;
}
export interface INewRuntimeOptions {
    eventBroadcaster: EventEmitter;
    eventDataCollector: EventDataCollector;
    newId: IdGenerator.NewId;
    options: IRuntimeOptions;
    pickleIds: string[];
    supportCodeLibrary: SupportCodeLibrary;
}
export interface IRuntimeOptions {
    dryRun: boolean;
    failFast: boolean;
    filterStacktraces: boolean;
    retry: number;
    retryTagFilter: string;
    strict: boolean;
    worldParameters: JsonObject;
}
export default class Runtime implements IRuntime {
    private readonly eventBroadcaster;
    private readonly eventDataCollector;
    private readonly stopwatch;
    private readonly newId;
    private readonly options;
    private readonly pickleIds;
    private readonly supportCodeLibrary;
    private success;
    private readonly runTestRunHooks;
    constructor({ eventBroadcaster, eventDataCollector, newId, options, pickleIds, supportCodeLibrary, }: INewRuntimeOptions);
    runTestCase(pickleId: string, testCase: messages.TestCase): Promise<void>;
    start(): Promise<boolean>;
}
