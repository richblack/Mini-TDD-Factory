"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const node_events_1 = require("node:events");
const node_url_1 = require("node:url");
const node_module_1 = require("node:module");
const messages_1 = require("@cucumber/messages");
const support_code_library_builder_1 = __importDefault(require("../../support_code_library_builder"));
const value_checker_1 = require("../../value_checker");
const run_test_run_hooks_1 = require("../run_test_run_hooks");
const stopwatch_1 = require("../stopwatch");
const test_case_runner_1 = __importDefault(require("../test_case_runner"));
const try_require_1 = __importDefault(require("../../try_require"));
const { uuid } = messages_1.IdGenerator;
class Worker {
    cwd;
    exit;
    id;
    eventBroadcaster;
    filterStacktraces;
    newId;
    sendMessage;
    supportCodeLibrary;
    worldParameters;
    runTestRunHooks;
    constructor({ cwd, exit, id, sendMessage, }) {
        this.id = id;
        this.newId = uuid();
        this.cwd = cwd;
        this.exit = exit;
        this.sendMessage = sendMessage;
        this.eventBroadcaster = new node_events_1.EventEmitter();
        this.eventBroadcaster.on('envelope', (envelope) => {
            this.sendMessage({ jsonEnvelope: envelope });
        });
    }
    async initialize({ supportCodeCoordinates, supportCodeIds, options, }) {
        support_code_library_builder_1.default.reset(this.cwd, this.newId, supportCodeCoordinates);
        supportCodeCoordinates.requireModules.map((module) => (0, try_require_1.default)(module));
        supportCodeCoordinates.requirePaths.map((module) => (0, try_require_1.default)(module));
        for (const specifier of supportCodeCoordinates.loaders) {
            (0, node_module_1.register)(specifier, (0, node_url_1.pathToFileURL)('./'));
        }
        for (const path of supportCodeCoordinates.importPaths) {
            await import((0, node_url_1.pathToFileURL)(path).toString());
        }
        this.supportCodeLibrary = support_code_library_builder_1.default.finalize(supportCodeIds);
        this.worldParameters = options.worldParameters;
        this.filterStacktraces = options.filterStacktraces;
        this.runTestRunHooks = (0, run_test_run_hooks_1.makeRunTestRunHooks)(options.dryRun, this.supportCodeLibrary.defaultTimeout, this.worldParameters, (name, location) => `${name} hook errored on worker ${this.id}, process exiting: ${location}`);
        await this.runTestRunHooks(this.supportCodeLibrary.beforeTestRunHookDefinitions, 'a BeforeAll');
        this.sendMessage({ ready: true });
    }
    async finalize() {
        await this.runTestRunHooks(this.supportCodeLibrary.afterTestRunHookDefinitions, 'an AfterAll');
        this.exit(0);
    }
    async receiveMessage(message) {
        if ((0, value_checker_1.doesHaveValue)(message.initialize)) {
            await this.initialize(message.initialize);
        }
        else if (message.finalize) {
            await this.finalize();
        }
        else if ((0, value_checker_1.doesHaveValue)(message.run)) {
            await this.runTestCase(message.run);
        }
    }
    async runTestCase({ gherkinDocument, pickle, testCase, elapsed, retries, skip, }) {
        const stopwatch = (0, stopwatch_1.create)(elapsed);
        const testCaseRunner = new test_case_runner_1.default({
            workerId: this.id,
            eventBroadcaster: this.eventBroadcaster,
            stopwatch,
            gherkinDocument,
            newId: this.newId,
            pickle,
            testCase,
            retries,
            skip,
            filterStackTraces: this.filterStacktraces,
            supportCodeLibrary: this.supportCodeLibrary,
            worldParameters: this.worldParameters,
        });
        await testCaseRunner.run();
        this.sendMessage({ ready: true });
    }
}
exports.default = Worker;
//# sourceMappingURL=worker.js.map