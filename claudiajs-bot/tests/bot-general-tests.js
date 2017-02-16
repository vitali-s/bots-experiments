'use strict';

var chai = require('chai');
var botEngine = require('../bot-engine');

var expect = chai.expect

describe('Bot should parse typical messages', function() {

  it('Known messages should be responsed appropriately', function() {
    var response = botEngine("How do you do?")
    expect(response).to.equal('very good :)');
  });

  it('Unknown messages should be responsed appropriately', function() {
    var response = botEngine("XXXXXX")
    expect(response).to.equal('I could not get your idea :(');
  });

  it('Known messages should be responsed appropriately', function() {
    var response = botEngine('<at id="28:3f2cae42-1cab-4d07-ae3d-d72818755829">@Sleepy Bot</at> How do you do?');
    expect(response).to.equal('very good :)');
  });

  it('Unknown messages should be responsed appropriately', function() {
    var response = botEngine('<at id="28:3f2cae42-1cab-4d07-ae3d-d72818755829">@Sleepy Bot</at> unknown message');
    expect(response).to.equal('I could not get your idea :(');
  });
});
