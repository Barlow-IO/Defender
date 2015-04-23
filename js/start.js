(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var Defender, Entity, GLOBALS,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Entity = require('./Entity.coffee');

GLOBALS = require('../globals.coffee');

Defender = (function(superClass) {
  extend(Defender, superClass);

  function Defender(x, y) {
    Defender.__super__.constructor.call(this, GLOBALS.DEFENDER_SIZE, x, y, 0, 0);
    this.health = this.healthMax = 12;
    this.score = 0;
    this.type = 'defender';
    this.armSize = 1.5;
    this.strokeWidth = this.size / 7;
    this.primaryColor = '#00b3ff';
    this.secondaryColor = '#23e96b';
    this.maxVelocity = 5;
    this.accel = 0.5;
    this.timeSinceDamaged = 0;
    this.DAMAGE_COOLDOWN = 30;
    this.timeSinceLazar = 0;
    this.LAZAR_COOLDOWN = 100;
    this.lazarRate = 1;
    this.currentCheckPoint = 0;
    this.makeBody();
    this.makeBindings();
  }

  Defender.prototype.makeBody = function() {
    this.arm0 = new Path.Line({
      from: this.pos + this.size,
      to: this.pos + (this.size * this.armSize),
      strokeColor: this.secondaryColor,
      strokeWidth: this.strokeWidth
    });
    this.arm1 = new Path.Line({
      from: [this.pos.x + this.size, this.pos.y - this.size],
      to: [this.pos.x + (this.size * this.armSize), this.pos.y - (this.size * this.armSize)],
      strokeColor: this.secondaryColor,
      strokeWidth: this.strokeWidth
    });
    this.arm2 = new Path.Line({
      from: this.pos - this.size,
      to: this.pos + (this.size * this.armSize * -1),
      strokeColor: this.secondaryColor,
      strokeWidth: this.strokeWidth
    });
    this.arm3 = new Path.Line({
      from: [this.pos.x - this.size, this.pos.y + this.size],
      to: [this.pos.x - (this.size * this.armSize), this.pos.y + (this.size * this.armSize)],
      strokeColor: this.secondaryColor,
      strokeWidth: this.strokeWidth
    });
    this.outerCircle = new Path.Circle({
      center: this.pos,
      radius: this.size,
      strokeColor: this.primaryColor,
      strokeWidth: this.strokeWidth
    });
    this.innerCircle = new Path.Circle({
      center: this.pos,
      radius: 1,
      strokeColor: this.secondaryColor,
      strokeWidth: this.strokeWidth
    });
    return this.body = new Group([this.arm0, this.arm1, this.arm2, this.arm3, this.outerCircle, this.innerCircle]);
  };

  Defender.prototype.makeBindings = function() {
    var $this;
    $this = this;
    GLOBALS.$mainCanvas.on(GLOBALS.ATTACKER_DEATH, function(event, entity) {
      return $this.onScore(entity);
    });
    return GLOBALS.$mainCanvas.on(GLOBALS.DEFENDER_HEALTH_GAIN, function(event, args) {
      return $this.onHealthGain(args.amount);
    });
  };

  Defender.prototype.update = function() {
    Defender.__super__.update.call(this);
    this.updateDirection();
    this.updateStats();
    return this.updateLazar();
  };

  Defender.prototype.updateStats = function() {
    if (this.score > 2) {
      return this.healthMax = 14;
    }
  };

  Defender.prototype.updateLazar = function() {
    var radius;
    if (this.timeSinceLazar < this.LAZAR_COOLDOWN) {
      this.timeSinceLazar += this.lazarRate;
    }
    radius = this.size / (this.LAZAR_COOLDOWN / this.timeSinceLazar);
    this.setInnerCircle(radius);
    if (this.timeSinceDamaged < this.DAMAGE_COOLDOWN) {
      return this.timeSinceDamaged += 1;
    }
  };

  Defender.prototype.move = function() {
    this.pos += this.v;
    return this.body.position = this.pos;
  };

  Defender.prototype.rotate = function() {
    return this.body.rotate(0.6);
  };

  Defender.prototype.damage = function(type) {
    if (type === 'attacker' && this.timeSinceDamaged === this.DAMAGE_COOLDOWN) {
      this.health--;
      this.timeSinceDamaged = 0;
      return this.timeSinceLazar = 0;
    }
  };

  Defender.prototype.canFireMahLazarz = function() {
    if (this.timeSinceLazar >= this.LAZAR_COOLDOWN) {
      return true;
    } else {
      return false;
    }
  };

  Defender.prototype.setInnerCircle = function(radius) {
    this.innerCircle.remove();
    return this.innerCircle = new Path.Circle({
      center: this.pos,
      radius: radius,
      strokeColor: this.secondaryColor,
      strokeWidth: this.strokeWidth
    });
  };

  Defender.prototype.raiseHealth = function() {
    this.maxHealth += 2;
    return GLOBALS.$mainCanvas.trigger(GLOBALS.MAX_HEALTH_GAIN);
  };

  Defender.prototype.onScore = function(entity) {
    this.score += entity.scoreValue;
    if (this.score % 10 === 0) {
      return this.raiseHealth();
    }
  };

  Defender.prototype.onHealthGain = function(amount) {
    if (this.health < this.healthMax) {
      return this.health += amount;
    }
  };

  return Defender;

})(Entity);

module.exports = Defender;



},{"../globals.coffee":4,"./Entity.coffee":2}],2:[function(require,module,exports){
var Entity, GLOBALS;

GLOBALS = require('../globals.coffee');

Entity = (function() {
  function Entity(size, x, y, vx, vy) {
    this.size = size;
    this.pos = new Point(x, y);
    this.v = new Point(vx, vy);
    this.alive = true;
    this.primaryColor = '#bab8b5';
  }

  Entity.prototype.updateDirection = function() {};

  Entity.prototype.update = function() {
    this.move();
    return this.rotate();
  };

  Entity.prototype.makeBody = function() {
    return this.body = new Path.Circle({
      center: [this.pos.x, this.pos.y],
      radius: this.size,
      strokeColor: this.strokeColor
    });
  };

  Entity.prototype.limitVelocity = function() {
    if (v.x > this.maxVelocity) {
      v.x = this.maxVelocity;
    }
    if (v.x < -this.maxVelocity) {
      v.x = -this.maxVelocity;
    }
    if (v.y > this.maxVelocity) {
      v.y = this.maxVelocity;
    }
    if (v.y < -this.maxVelocity) {
      return v.y = -this.maxVelocity;
    }
  };

  Entity.prototype.damage = function(type) {};

  Entity.prototype.move = function() {
    this.pos += this.v;
    return this.body.position = this.pos;
  };

  Entity.prototype.rotate = function() {};

  return Entity;

})();

module.exports = Entity;



},{"../globals.coffee":4}],3:[function(require,module,exports){
var Entity, GLOBALS, Laser,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Entity = require('./Entity.coffee');

GLOBALS = require('../globals.coffee');

Laser = (function(superClass) {
  extend(Laser, superClass);

  function Laser(num, defender) {
    var vx, vy;
    this.num = num;
    this.defender = defender;
    this.reference = this.defender['arm' + this.num];
    this.from = this.reference.segments[0].point;
    this.to = this.reference.segments[1].point;
    vx = (this.to.x - this.from.x) / 2;
    vy = (this.to.y - this.from.y) / 2;
    Laser.__super__.constructor.call(this, GLOBALS.LASER_SIZE, this.reference.position.x, this.reference.position.y, vx, vy);
    this.primaryColor = '#23e96b';
    this.type = 'laser';
    this.magnitude = 15;
    this.makeBody();
  }

  Laser.prototype.makeBody = function() {
    this.pos.x = this.reference.position.x;
    this.pos.y = this.reference.position.y;
    return this.body = new Path.Line({
      from: [this.from.x, this.from.y],
      to: [this.to.x, this.to.y],
      strokeColor: this.primaryColor,
      strokeWidth: GLOBALS.DEFENDER_SIZE / 7
    });
  };

  Laser.prototype.update = function() {
    return this.move();
  };

  Laser.prototype.damage = function(type) {
    if (type === 'true') {
      return this.alive = false;
    }
  };

  return Laser;

})(Entity);

module.exports = Laser;



},{"../globals.coffee":4,"./Entity.coffee":2}],4:[function(require,module,exports){
module.exports = {
  $mainCanvas: $('#mainCanvas'),
  ATTACKER_DEATH: 'attacker-death',
  MAX_HEALTH_GAIN: 'maxHealth-gain',
  DEFENDER_HEALTH_GAIN: 'defender-health-gain',
  DEFENDER_INVULNERABLE: 'defender-invulnerable',
  DEFENDER_DAMAGED: 'defender-damaged',
  FRICTION: 0.6,
  SPRING: 0.6,
  DEFENDER_SIZE: $(window).width() / 50,
  ATTACKER_SIZE: $(window).width() / 50,
  LASER_SIZE: $(window).width() / 60,
  POWERUP_SIZE: $(window).width() / 65
};



},{}],5:[function(require,module,exports){
var Defender, GLOBALS, Game, Laser;

String.prototype.repeat = function(num) {
  return new Array(num + 1).join(this);
};

Defender = require('../entities/Defender.coffee');

Laser = require('../entities/Laser.coffee');

GLOBALS = require('../globals.coffee');

Game = (function() {
  function Game() {
    this.entities = [];
    this.makeEntities();
    this.makeBindings();
    this.init();
  }

  Game.prototype.init = function() {
    var $this, mainloop;
    $this = this;
    mainloop = function() {
      return $this.mainloop();
    };
    return setInterval(mainloop, 16);
  };

  Game.prototype.makeEntities = function() {
    this.defender = new Defender(view.center.x, view.center.y - 200);
    this.defender.v = new Point(_.random(-5, 5), _.random(-5, 5));
    return this.entities.push(this.defender);
  };

  Game.prototype.makeBindings = function() {
    var $this;
    return $this = this;
  };

  Game.prototype.handleInput = function() {
    if (Key.isDown('a') || Key.isDown('left')) {
      if (this.defender.v.x > -this.defender.maxVelocity) {
        this.defender.v.x -= this.defender.accel;
      }
    }
    if (Key.isDown('w') || Key.isDown('up')) {
      if (this.defender.v.y > -this.defender.maxVelocity) {
        this.defender.v.y -= this.defender.accel;
      }
    }
    if (Key.isDown('d') || Key.isDown('right')) {
      if (this.defender.v.x < this.defender.maxVelocity) {
        this.defender.v.x += this.defender.accel;
      }
    }
    if (Key.isDown('s') || Key.isDown('down')) {
      if (this.defender.v.y < this.defender.maxVelocity) {
        this.defender.v.y += this.defender.accel;
      }
    }
    if (Key.isDown('shift')) {
      console.log('shiftaki');
    }
    if (Key.isDown('space')) {
      if (this.defender.canFireMahLazarz()) {
        this.fireMahLazarz();
      }
    }
    if (Key.isDown('escape')) {
      return this.defender.v = new Point(0, 0);
    }
  };

  Game.prototype.mainloop = function() {
    this.handleInput();
    this.updateEntities();
    this.checkCollisions();
    this.keepInBounds();
    this.updateDeadEntities();
    console.log;
    return view.draw();
  };

  Game.prototype.updateEntities = function() {
    var entity, j, len, ref;
    ref = this.entities;
    for (j = 0, len = ref.length; j < len; j++) {
      entity = ref[j];
      entity.update();
    }
    if (this.numAttackers < this.ATTACKER_AMOUNT) {
      return this.spawnAttacker();
    }
  };

  Game.prototype.updateDeadEntities = function() {
    var entity, j, len, ref, results;
    ref = this.entities;
    results = [];
    for (j = 0, len = ref.length; j < len; j++) {
      entity = ref[j];
      if (entity.alive === false) {
        if (entity.type === 'attacker') {
          GLOBALS.$mainCanvas.trigger(GLOBALS.ATTACKER_DEATH, entity);
        }
        entity.body.remove();
        results.push(this.entities.splice(this.entities.indexOf(entity), 1));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  Game.prototype.kill = function(entity) {
    return entity.alive = false;
  };

  Game.prototype.fireMahLazarz = function() {
    var entity, i, j, k, len, ref, results;
    this.defender.timeSinceLazar = 0;
    ref = this.entities;
    for (j = 0, len = ref.length; j < len; j++) {
      entity = ref[j];
      if (entity.type === 'laser') {
        this.kill(entity);
      }
    }
    results = [];
    for (i = k = 0; k < 4; i = k += 1) {
      results.push(this.entities.push(new Laser(i, this.defender)));
    }
    return results;
  };

  Game.prototype.checkCollisions = function(index) {
    var e, j, ref, ref1;
    if (index == null) {
      index = 0;
    }
    for (e = j = ref = index + 1, ref1 = this.entities.length; j < ref1; e = j += 1) {
      if (this.entities[index].pos.getDistance(this.entities[e].pos) <= this.entities[index].size + this.entities[e].size) {
        this.collide(this.entities[e], this.entities[index]);
        this.collide(this.entities[index], this.entities[e]);
        this.entities[e].damage(this.entities[index].type);
        this.entities[index].damage(this.entities[e].type);
      }
    }
    if (index + 1 < this.entities.length) {
      return this.checkCollisions(index + 1);
    }
  };

  Game.prototype.collide = function(e1, e2) {
    var angle, ax, ay, dx, dy, minDist, targetX, targetY;
    dx = e1.pos.x - e2.pos.x;
    dy = e1.pos.y - e2.pos.y;
    angle = Math.atan2(dy, dx);
    minDist = e1.size + e2.size;
    targetX = e1.pos.x + Math.cos(angle) * minDist;
    targetY = e2.pos.y + Math.sin(angle) * minDist;
    ax = (targetX - e2.pos.x) * GLOBALS.SPRING / 50;
    ay = (targetY - e2.pos.y) * GLOBALS.SPRING / 50;
    return e1.v += new Point(ax, ay);
  };

  Game.prototype.keepInBounds = function() {
    var entity, j, len, ref, results;
    ref = this.entities;
    results = [];
    for (j = 0, len = ref.length; j < len; j++) {
      entity = ref[j];
      if (entity.pos.x < entity.size) {
        entity.v *= new Point(-GLOBALS.SPRING, GLOBALS.SPRING);
        entity.pos.x = entity.size;
        if (entity.type === 'laser') {
          this.kill(entity);
        }
      }
      if (entity.pos.y < entity.size) {
        entity.v *= new Point(GLOBALS.SPRING, -GLOBALS.SPRING);
        entity.pos.y = entity.size;
        if (entity.type === 'laser') {
          this.kill(entity);
        }
      }
      if (entity.pos.x > view.bounds.width - entity.size) {
        entity.v *= new Point(-GLOBALS.SPRING, GLOBALS.SPRING);
        entity.pos.x = view.bounds.width - entity.size;
        if (entity.type === 'laser') {
          this.kill(entity);
        }
      }
      if (entity.pos.y > view.bounds.height - entity.size) {
        entity.v *= new Point(GLOBALS.SPRING, -GLOBALS.SPRING);
        entity.pos.y = view.bounds.height - entity.size;
        if (entity.type === 'laser') {
          results.push(this.kill(entity));
        } else {
          results.push(void 0);
        }
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  return Game;

})();

module.exports = Game;



},{"../entities/Defender.coffee":1,"../entities/Laser.coffee":3,"../globals.coffee":4}],6:[function(require,module,exports){
var Background, background;

Background = require('./screens/Background.coffee');

background = new Background();



},{"./screens/Background.coffee":5}]},{},[6]);
