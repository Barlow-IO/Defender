Powerup = require './Powerup.coffee'
GLOBALS = require '../../globals.coffee'


class HealthUpDouble extends Powerup
    constructor: (x, y) ->
        super x, y
        @makeBody()

    trigger: GLOBALS.DEFENDER_HEALTH_GAIN
    args: {
        amount: 2
    }

    makeBody: () ->
        @heart1 = new PointText(
            point: [@pos.x, @pos.y],
            content: '♡',
            fillColor: '#f24e3f',
            fontFamily: 'Courier New',
            fontSize: 25
        );

        @heart2 = new PointText(
            point: [@pos.x + 7, @pos.y - 7],
            content: '♡',
            fillColor: '#f24e3f',
            fontFamily: 'Courier New',
            fontSize: 25
        );

        @body = new Group([@heart1, @heart2])

module.exports = HealthUpDouble
