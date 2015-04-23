Entity = require './Entity.coffee'
GLOBALS = require '../globals.coffee'

class Attacker extends Entity
    constructor: (size, x, y, target) ->
        super size, x, y, _.random(-5, 5), _.random(-5, 5)

        @rotation = 0
        @target = target
        @type = 'attacker'
        @maxVelocity = 10
        @strokeWidth = @size / 10
        @primaryColor = '#f24e3f'
        @accel = 0.1
        @scoreValue = 1

        @makeBody()

    makeBody: () ->
        @body = new Path({
                segments: [
                    new Segment({
                        point: [@pos.x + @size, @pos.y - @size]
                    })
                    new Segment({
                        point: [@pos.x - @size, @pos.y - @size]
                    })
                    new Segment({
                        point: [@pos.x, @pos.y + @size]
                    })
                ]
                strokeColor: @primaryColor
                strokeWidth: @strokeWidth
                closed: true
            })

    update: () ->
        @trackTarget()
        @move()
        @updateDirection()
        # @rotate()

    trackTarget: () ->
        @v.x -= @accel if @target.pos.x < @pos.x # defender to the left
        @v.y -= @accel if @target.pos.y < @pos.y # defender is above
        @v.x += @accel if @target.pos.x > @pos.x # defender to the right
        @v.y += @accel if @target.pos.y > @pos.y # defender is below

    move: () ->
        @pos += @v # entity position changes
        @body.position = @pos # body position changes

    rotate: () ->
        #find theta... 'Theta!? Where are you, Theta?'
        theta = Math.atan(@v.y / @v.x) * (180 / Math.PI) - 90 # convert to degrees
        theta += 180 if @v.x < 0 # make sure theta is within the range
        @body.rotation = theta if theta != @body.data.rotation
        @body.data.rotation = theta

    damage: (type) ->
        if type == 'laser'
            @alive = false

module.exports = Attacker
