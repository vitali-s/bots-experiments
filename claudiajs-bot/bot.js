'use strict';

var botBuilder = require('claudia-bot-builder');
var botEngine = require('./bot-engine');

module.exports = botBuilder(function (request) {
    return botEngine(request.text);
});