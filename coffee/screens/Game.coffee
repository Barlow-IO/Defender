String::repeat = ( num ) ->
    #I'm sorry for extending a primitive type, but it must be done
    return new Array( num + 1 ).join( this );

Defender = require '../entities/Defender.coffee'
Attacker = require '../entities/Attacker.coffee'
Laser = require '../entities/Laser.coffee'
HealthUp = require '../entities/powerups/HealthUp.coffee'
HealthUpDouble = require '../entities/powerups/HealthUpDouble.coffee'
InvulnerableUp = require '../entities/powerups/InvulnerableUp.coffee'
GLOBALS = require '../globals.coffee'

#TODO: make level class
class Game
    constructor: () ->
        @entities = []
        @difficulty = 1
        @ATTACKER_AMOUNT = Math.floor(@difficulty * 3)
        @numAttackers = 0

        @makeEntities()
        @makeBindings()
        # @makeStars()

        @healthFull = $('#healthContainer')
        @healthBar  = $('#health')
        @injuryBar  = $('#injury')
        @scoreBar   = $('#score')

        @init()

    init: () ->
        $this = this
        mainloop = () ->
            $this.mainloop()

        setTimeout () ->
            $('#countdownText').text('THREE')
        , 0

        setTimeout ->
            $('#countdownText').text('TWO')
        , 750 # 1000 ms is too long, 750 is better, even though it's not a full second
        setTimeout ->
            $('#countdownText').text('ONE')
        , 750 * 2

        setTimeout ->
            $('#countdownText').text('')
            setInterval(mainloop, 16)
        , 750 * 3

    makeEntities: () ->
        @defender = new Defender(view.center.x, view.center.y)
        @entities.push @defender

        @entities.push new InvulnerableUp(view.center.x + 100, view.center.y + 100)

        for i in [0..@ATTACKER_AMOUNT] by 1
            @numAttackers++
            @entities.push new Attacker(
                GLOBALS.ATTACKER_SIZE,
                view.center.x + _.random(-500, 500),
                view.center.y + _.random(-500, 500),
                @defender
            )

    makeBindings: () ->
        $this = this
        GLOBALS.$mainCanvas.on(GLOBALS.ATTACKER_DEATH, ->
            $this.spawnAttacker()
            $this.animateScoreBar()
        )
        GLOBALS.$mainCanvas.on(GLOBALS.MAX_HEALTH_GAIN, ->
            $this.animateHealthBar()
        )

    makeStars: () ->
        starLayer = new Layer({
            # children: ,
            strokeColor: 'white'
            strokeWidth: 3
            position: view.center
        })

        for i in [0..$(window).width() / 3] by 1
            starLayer.children.push new Path.Circle {
                radius: _.random 5, 5
                point: _.random $(window).width(), $(window).height()
                strokeColor: 'white'
                strokeWidth: 3
                }

    handleInput: () ->
        if Key.isDown('a') or Key.isDown('left') # left
            @defender.v.x -= @defender.accel if @defender.v.x > -@defender.maxVelocity
        if Key.isDown('w') or Key.isDown('up') # up
            @defender.v.y -= @defender.accel if @defender.v.y > -@defender.maxVelocity
        if Key.isDown('d') or Key.isDown('right') # right
            @defender.v.x += @defender.accel if @defender.v.x < @defender.maxVelocity
        if Key.isDown('s') or Key.isDown('down') # down
            @defender.v.y += @defender.accel if @defender.v.y < @defender.maxVelocity
        if Key.isDown('shift')
            console.log 'shiftaki'
        if Key.isDown('space')
            if @defender.canFireMahLazarz()
                @fireMahLazarz()
        if Key.isDown('escape')
            @defender.v = new Point(0, 0) # stop defender

    mainloop: () ->
        @handleInput()
        @updateEntities()
        @checkCollisions()
        @keepInBounds()
        @updateRandomSpawns()
        @updateScoreBar()
        @updateHealthBar()
        @updateDeadEntities()

        view.draw()

    updateEntities: () ->
        for entity in @entities
            entity.update()

        if @numAttackers < @ATTACKER_AMOUNT
            @spawnAttacker()

    updateHealthBar: () ->
        if @defender.health >= 0
            @healthBar.text('♡'.repeat(@defender.health))
            @injuryBar.text('♡'.repeat(@defender.healthMax - @defender.health))

    updateScoreBar: () ->
        @scoreBar.text(@defender.score)

    updateDeadEntities: () ->
        for entity in @entities
            if entity.alive == false
                GLOBALS.$mainCanvas.trigger(GLOBALS.ATTACKER_DEATH, entity) if entity.type == 'attacker' # trigger jQuery event
                entity.body.remove() #remove the entity body from the view
                @entities.splice(@entities.indexOf(entity), 1) #remove entity from @entities array

    updateRandomSpawns: () ->
        if _.random(500) == 1
            @entities.push new HealthUp(
                view.center.x + _.random(-500, 500),
                view.center.y + _.random(-500, 500)
            )
        else if _.random(700) == 1
            @entities.push new HealthUpDouble(
                view.center.x + _.random(-500, 500),
                view.center.y + _.random(-500, 500)
            )

    kill: (entity) ->
        # sets the entity to be destroyed in updateDeadEntities
        entity.alive = false

    animateHealthBar: () ->
        # class to add to health and injury bars
        animation = 'animated rubberBand'
        # ton of crap to check when animations end
        animationEnd = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend'

        # add animation to health bar and injury bar
        @healthBar.addClass(animation)
        @injuryBar.addClass(animation)
        @healthBar.one(animationEnd, -> # use '.one' so it will activate, then unbind
            # remove animation classes from elements
            $(this).removeClass(animation)
            $('#injury').removeClass(animation)
        )

    animateScoreBar: () ->
        #see comments above in animateHealthBar
        animation = 'animated rubberBand'
        animationEnd = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend'
        @scoreBar.addClass(animation)
        @scoreBar.one(animationEnd, -> $(this).removeClass(animation))

    spawnAttacker: () ->
        #creates a new Attacker
        @entities.push new Attacker(
            GLOBALS.ATTACKER_SIZE,
            view.center.x + _.random(-500, 500),
            view.center.y + _.random(-500, 500),
            @defender
        )

    fireMahLazarz: () ->
        @defender.timeSinceLazar = 0
        for entity in @entities
            #kill all existing lasers... just in case
            if entity.type == 'laser'
                @kill(entity)

        for i in [0...4] by 1
            #spawn four new lasers
            @entities.push new Laser(i, @defender)

    checkCollisions: (index) ->
        index ?= 0

        for e in [index + 1...@entities.length] by 1
            if @entities[index].pos.getDistance(@entities[e].pos) <= @entities[index].size + @entities[e].size
                #collide each entity with the other entity
                @collide(@entities[e], @entities[index])
                @collide(@entities[index], @entities[e])

                @entities[e].damage(@entities[index].type)
                @entities[index].damage(@entities[e].type)

        if index + 1 < @entities.length
            return @checkCollisions(index + 1)

    collide: (e1, e2) ->
        #math. I just know it works. I kinda understand it... but not well
        dx = e1.pos.x - e2.pos.x
        dy = e1.pos.y - e2.pos.y

        angle = Math.atan2(dy, dx)
        minDist = e1.size + e2.size

        targetX = e1.pos.x + Math.cos(angle) * minDist
        targetY = e2.pos.y + Math.sin(angle) * minDist

        ax = (targetX - e2.pos.x) * GLOBALS.SPRING / 50
        ay = (targetY - e2.pos.y) * GLOBALS.SPRING / 50

        e1.v += new Point ax, ay

    keepInBounds: () ->
        for entity in @entities
            if entity.pos.x < entity.size
                #collide on left wall
                entity.v *= new Point -GLOBALS.SPRING, GLOBALS.SPRING
                entity.pos.x = entity.size
                @kill entity if entity.type == 'laser'

            if entity.pos.y < entity.size
                #collide on top wall
                entity.v *= new Point GLOBALS.SPRING, -GLOBALS.SPRING
                entity.pos.y = entity.size
                @kill entity if entity.type == 'laser'

            if entity.pos.x > view.bounds.width - entity.size
                #collide on right wall
                entity.v *= new Point -GLOBALS.SPRING, GLOBALS.SPRING
                entity.pos.x = view.bounds.width - entity.size
                @kill entity if entity.type == 'laser'

            if entity.pos.y > view.bounds.height - entity.size
                #collide on bottom wall
                entity.v *= new Point GLOBALS.SPRING, -GLOBALS.SPRING
                entity.pos.y = view.bounds.height - entity.size
                @kill entity if entity.type == 'laser'

module.exports = Game
