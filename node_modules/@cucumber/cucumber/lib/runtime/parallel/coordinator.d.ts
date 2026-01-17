/// <reference types="node" />
/// <reference types="node" />
import { ChildProcess } from 'node:child_process';
import { EventEmitter } from 'node:events';
import * as messages from '@cucumber/messages';
import { IdGenerator } from '@cucumber/messages';
import { EventDataCollector } from '../../formatter/helpers';
import { IRuntime, IRuntimeOptions } from '..';
import { SupportCodeLibrary } from '../../support_code_library_builder/types';
import { ILogger } from '../../logger';
import { ICoordinatorReport } from './command_types';
export interface INewCoordinatorOptions {
    cwd: string;
    logger: ILogger;
    eventBroadcaster: EventEmitter;
    eventDataCollector: EventDataCollector;
    options: IRuntimeOptions;
    newId: IdGenerator.NewId;
    pickleIds: string[];
    supportCodeLibrary: SupportCodeLibrary;
    numberOfWorkers: number;
}
declare const enum WorkerState {
    'idle' = 0,
    'closed' = 1,
    'running' = 2,
    'new' = 3
}
interface IWorker {
    state: WorkerState;
    process: ChildProcess;
    id: string;
}
interface IPicklePlacement {
    index: number;
    pickle: messages.Pickle;
}
export default class Coordinator implements IRuntime {
    private readonly cwd;
    private readonly eventBroadcaster;
    private readonly eventDataCollector;
    private readonly stopwatch;
    private onFinish;
    private readonly options;
    private readonly newId;
    private readonly pickleIds;
    private assembledTestCases;
    private readonly inProgressPickles;
    private readonly workers;
    private readonly supportCodeLibrary;
    private readonly numberOfWorkers;
    private readonly logger;
    private success;
    private idleInterventions;
    constructor({ cwd, logger, eventBroadcaster, eventDataCollector, pickleIds, options, newId, supportCodeLibrary, numberOfWorkers, }: INewCoordinatorOptions);
    parseWorkerMessage(worker: IWorker, message: ICoordinatorReport): void;
    awakenWorkers(triggeringWorker: IWorker): void;
    startWorker(id: string, total: number): void;
    onWorkerProcessClose(exitCode: number): void;
    parseTestCaseResult(testCaseFinished: messages.TestCaseFinished, workerId: string): void;
    start(): Promise<boolean>;
    nextPicklePlacement(): IPicklePlacement;
    placementAt(index: number): IPicklePlacement;
    giveWork(worker: IWorker, force?: boolean): void;
}
export {};
