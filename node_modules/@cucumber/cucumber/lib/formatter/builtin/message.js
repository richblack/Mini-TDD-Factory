"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = {
    type: 'formatter',
    formatter({ on, write }) {
        on('message', (message) => write(JSON.stringify(message) + '\n'));
    },
    documentation: 'Emits Cucumber messages in NDJSON format',
};
//# sourceMappingURL=message.js.map