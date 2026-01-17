/// <reference types="node" />
/// <reference types="node" />
/// <reference types="node" />
import { EventEmitter } from 'node:events';
import { Readable } from 'node:stream';
import { IdGenerator } from '@cucumber/messages';
import { EventDataCollector } from '../formatter/helpers';
import PickleFilter from '../pickle_filter';
import { SupportCodeLibrary } from '../support_code_library_builder/types';
import { ILogger } from '../logger';
import { IPickleOrder } from '../filter';
interface IParseGherkinMessageStreamRequest {
    cwd?: string;
    eventBroadcaster: EventEmitter;
    eventDataCollector: EventDataCollector;
    gherkinMessageStream: Readable;
    order: string;
    pickleFilter: PickleFilter;
}
/**
 * Process a stream of envelopes from Gherkin and resolve to an array of filtered, ordered pickle Ids
 *
 * @param eventBroadcaster
 * @param eventDataCollector
 * @param gherkinMessageStream
 * @param order
 * @param pickleFilter
 */
export declare function parseGherkinMessageStream({ eventBroadcaster, eventDataCollector, gherkinMessageStream, order, pickleFilter, }: IParseGherkinMessageStreamRequest): Promise<string[]>;
export declare function orderPickles<T = string>(pickleIds: T[], order: IPickleOrder, logger: ILogger): void;
export declare function emitMetaMessage(eventBroadcaster: EventEmitter, env: NodeJS.ProcessEnv): Promise<void>;
export declare function emitSupportCodeMessages({ eventBroadcaster, supportCodeLibrary, newId, }: {
    eventBroadcaster: EventEmitter;
    supportCodeLibrary: SupportCodeLibrary;
    newId: IdGenerator.NewId;
}): void;
export {};
