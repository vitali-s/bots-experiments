'use strict';

const botName = '@Sleepy Bot'
const dictonary = {
    'how do you do?': 'very good :)'
}

module.exports = function botEngine(message) {
    var messageRegexp = /^\<\at\sid=\"(.*)"\>(.*)\<\/\at\>\s(.*)$/gi;
    var match = messageRegexp.exec(message);

    if (match && match[2] == botName && match[3]) {
        message = match[3]
    }

    // normalize message
    message = message.trim().toLowerCase();

    var response = dictonary[message];

    if (response) {
        return response;
    }

    return 'I could not get your idea :(';
};