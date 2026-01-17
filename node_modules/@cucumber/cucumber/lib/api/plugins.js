"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.initializeForRunCucumber = exports.initializeForLoadSupport = exports.initializeForLoadSources = void 0;
const plugin_1 = require("../plugin");
const publish_1 = __importDefault(require("../publish"));
const filter_1 = __importDefault(require("../filter"));
async function initializeForLoadSources(logger, coordinates, environment) {
    // eventually we'll load plugin packages here
    const pluginManager = new plugin_1.PluginManager();
    await pluginManager.initCoordinator('loadSources', filter_1.default, coordinates, logger, environment);
    return pluginManager;
}
exports.initializeForLoadSources = initializeForLoadSources;
async function initializeForLoadSupport() {
    // eventually we'll load plugin packages here
    return new plugin_1.PluginManager();
}
exports.initializeForLoadSupport = initializeForLoadSupport;
async function initializeForRunCucumber(logger, configuration, environment) {
    // eventually we'll load plugin packages here
    const pluginManager = new plugin_1.PluginManager();
    await pluginManager.initCoordinator('runCucumber', publish_1.default, configuration.formats.publish, logger, environment);
    await pluginManager.initCoordinator('runCucumber', filter_1.default, configuration.sources, logger, environment);
    return pluginManager;
}
exports.initializeForRunCucumber = initializeForRunCucumber;
//# sourceMappingURL=plugins.js.map