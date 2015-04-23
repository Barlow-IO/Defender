GLOBALS = require '../globals.coffee'

class Entity
    constructor: (size, x, y, vx, vy) ->
        @size = size
        @pos = new Point(x, y)
        @v = new Point(vx, vy)
        @alive = true
        @primaryColor = '#bab8b5'
        # @direction = new Path.Line({
        #     from: [@pos.x, @pos.y]
        #     to:   [@pos.x + (@v.x * 10), @pos.y + (@v.y * 10)]
        #     strokeColor: '#ffffff'
        #     strokeWidth: 5
        #     })

    updateDirection: () ->
        # @direction.segments[0] = new Segment({ point: [@pos.x, @pos.y]})
        # @direction.segments[1] = new Segment({ point: [@pos.x + (@v.x * 10), @pos.y + (@v.y * 10)]})

    update: () ->
        @move()
        @rotate()

    makeBody: () ->
        @body = new Path.Circle({
            center: [@pos.x, @pos.y],
            radius: @size,
            strokeColor: @strokeColor
        })

    limitVelocity: () ->
        v.x = @maxVelocity if v.x > @maxVelocity
        v.x = -@maxVelocity if v.x < -@maxVelocity
        v.y = @maxVelocity if v.y > @maxVelocity
        v.y = -@maxVelocity if v.y < -@maxVelocity

    damage: (type) ->

    move: () ->
        @pos += @v # add velocity to position
        @body.position = @pos # move @body to @pos

    rotate: () ->

module.exports = Entity
