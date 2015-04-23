String::repeat = ( num ) ->
    #I'm sorry for extending a primitive type, but it must be done
    return new Array( num + 1 ).join( this );

Defender = require '../entities/Defender.coffee'
Laser = require '../entities/Laser.coffee'
GLOBALS = require '../globals.coffee'

#TODO: make level class
class Game
    constructor: () ->
        @entities = []
        @makeEntities()
        @makeBindings()
        @init()

    init: () ->
        $this = this
        mainloop = () ->
            $this.mainloop()
        setInterval(mainloop, 16)

    makeEntities: () ->
        @defender = new Defender(view.center.x, view.center.y - 200)
        @defender.v = new Point(_.random(-5, 5), _.random(-5, 5))
        @entities.push @defender

    makeBindings: () ->
        $this = this

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
        @updateDeadEntities()
        console.log 
        view.draw()

    updateEntities: () ->
        for entity in @entities
            entity.update()

        if @numAttackers < @ATTACKER_AMOUNT
            @spawnAttacker()

    updateDeadEntities: () ->
        for entity in @entities
            if entity.alive == false
                GLOBALS.$mainCanvas.trigger(GLOBALS.ATTACKER_DEATH, entity) if entity.type == 'attacker' # trigger jQuery event
                entity.body.remove() #remove the entity body from the view
                @entities.splice(@entities.indexOf(entity), 1) #remove entity from @entities array

    kill: (entity) ->
        # sets the entity to be destroyed in updateDeadEntities
        entity.alive = false

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
