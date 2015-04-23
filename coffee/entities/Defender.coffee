Entity = require './Entity.coffee'
GLOBALS = require '../globals.coffee'

class Defender extends Entity
    constructor: (x, y) ->
        super GLOBALS.DEFENDER_SIZE, x, y, 0, 0

        @health = @healthMax = 12
        @score = 0
        @type = 'defender'
        @armSize = 1.5
        @strokeWidth = @size / 7
        @primaryColor = '#00b3ff'
        @secondaryColor = '#23e96b'
        @maxVelocity = 5
        @accel = 0.5
        @timeSinceDamaged = 0
        @DAMAGE_COOLDOWN = 30
        @timeSinceLazar = 0
        @LAZAR_COOLDOWN = 100
        @lazarRate = 1
        @currentCheckPoint = 0

        @makeBody()
        @makeBindings()

    makeBody: () ->
        #Bottom Right
        @arm0 = new Path.Line({
                from: @pos + @size
                to: @pos + (@size * @armSize)
                strokeColor: @secondaryColor
                strokeWidth: @strokeWidth
            })
        #Top Right
        @arm1 = new Path.Line({
                from: [@pos.x + @size, @pos.y - @size]
                to: [@pos.x + (@size * @armSize), @pos.y - (@size * @armSize)]
                strokeColor: @secondaryColor
                strokeWidth: @strokeWidth
            })
        #Top Left
        @arm2 = new Path.Line({
                from: @pos - @size
                to: @pos + (@size * @armSize * -1)
                strokeColor: @secondaryColor
                strokeWidth: @strokeWidth
            })
        #Bottom Left
        @arm3 = new Path.Line({
                from: [@pos.x - @size, @pos.y + @size]
                to: [@pos.x - (@size * @armSize), @pos.y + (@size * @armSize)]
                strokeColor: @secondaryColor
                strokeWidth: @strokeWidth
            })
        @outerCircle = new Path.Circle({
                center: @pos
                radius: @size
                strokeColor: @primaryColor
                strokeWidth: @strokeWidth
            })
        @innerCircle = new Path.Circle({
                center: @pos
                radius: 1 # @size * 0.6
                strokeColor: @secondaryColor
                strokeWidth: @strokeWidth
            })

        @body = new Group([@arm0, @arm1, @arm2, @arm3, @outerCircle, @innerCircle])

    makeBindings: () ->
        $this = this
        GLOBALS.$mainCanvas.on(GLOBALS.ATTACKER_DEATH, (event, entity) -> $this.onScore(entity))
        GLOBALS.$mainCanvas.on(GLOBALS.DEFENDER_HEALTH_GAIN, (event, args)-> $this.onHealthGain(args.amount))

    update: () ->
        super()
        @updateDirection()
        @updateStats()
        @updateLazar()

    updateStats: () ->
        if @score > 2
            @healthMax = 14

    updateLazar: () ->
        @timeSinceLazar += @lazarRate if @timeSinceLazar < @LAZAR_COOLDOWN
        radius = (@size) / (@LAZAR_COOLDOWN / @timeSinceLazar)
        @setInnerCircle(radius)
        @timeSinceDamaged += 1 if @timeSinceDamaged < @DAMAGE_COOLDOWN

    move: () ->
        @pos += @v # add velocity to position
        @body.position = @pos # move @body to @pos

    rotate: () ->
        @body.rotate(0.6)

    damage: (type) ->
        if type == 'attacker' and @timeSinceDamaged == @DAMAGE_COOLDOWN
            @health--
            @timeSinceDamaged = 0
            @timeSinceLazar = 0

    canFireMahLazarz: ()->
        if @timeSinceLazar >= @LAZAR_COOLDOWN
            return true
        else
            return false

    setInnerCircle: (radius) ->
        @innerCircle.remove()

        @innerCircle = new Path.Circle({
                center: @pos
                radius: radius
                strokeColor: @secondaryColor
                strokeWidth: @strokeWidth
            })

    raiseHealth: () ->
        @maxHealth += 2
        GLOBALS.$mainCanvas.trigger(GLOBALS.MAX_HEALTH_GAIN)

    onScore: (entity) ->
        @score += entity.scoreValue
        @raiseHealth() if @score % 10 == 0

    onHealthGain: (amount) ->
        @health += amount if @health < @healthMax

module.exports = Defender
