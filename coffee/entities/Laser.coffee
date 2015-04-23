Entity = require './Entity.coffee'
GLOBALS = require '../globals.coffee'

class Laser extends Entity
    constructor: (@num, @defender) ->

        @reference = @defender['arm' + @num]
        @from = @reference.segments[0].point
        @to   = @reference.segments[1].point
        vx = (@to.x - @from.x) / 2
        vy = (@to.y - @from.y) / 2
        super  GLOBALS.LASER_SIZE, @reference.position.x, @reference.position.y, vx, vy
        @primaryColor = '#23e96b'
        @type = 'laser'
        @magnitude = 15

        @makeBody()

    makeBody: () ->
        @pos.x = @reference.position.x
        @pos.y = @reference.position.y

        @body = new Path.Line({
            from: [@from.x, @from.y]
            to:   [@to.x, @to.y]
            strokeColor: @primaryColor
            strokeWidth: GLOBALS.DEFENDER_SIZE / 7
        })

    update: () ->
        @move()

    damage: (type) ->
        if type == 'true'
            @alive = false

module.exports = Laser
