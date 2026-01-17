"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.mergeEnvironment = void 0;
const console_logger_1 = require("./console_logger");
function mergeEnvironment(provided) {
    const fullEnvironment = Object.assign({}, {
        cwd: process.cwd(),
        stdout: process.stdout,
        stderr: process.stderr,
        env: process.env,
        debug: false,
    }, provided);
    const logger = new console_logger_1.ConsoleLogger(fullEnvironment.stderr, fullEnvironment.debug);
    logger.debug('Resolved environment:', fullEnvironment);
    return {
        ...fullEnvironment,
        logger: logger,
    };
}
exports.mergeEnvironment = mergeEnvironment;
//# sourceMappingURL=environment.js.map