/// <reference types="node" />
import { EventEmitter } from 'node:events';
import * as messages from '@cucumber/messages';
import { IdGenerator } from '@cucumber/messages';
import { SupportCodeLibrary } from '../support_code_library_builder/types';
export declare type IAssembledTestCases = Record<string, messages.TestCase>;
export interface IAssembleTestCasesOptions {
    eventBroadcaster: EventEmitter;
    newId: IdGenerator.NewId;
    pickles: messages.Pickle[];
    supportCodeLibrary: SupportCodeLibrary;
}
export declare function assembleTestCases({ eventBroadcaster, newId, pickles, supportCodeLibrary, }: IAssembleTestCasesOptions): Promise<IAssembledTestCases>;
