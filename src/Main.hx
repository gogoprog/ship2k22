import js.Browser.document;
import js.Browser.window;
import w.W;

typedef Bullet = {
    var x:Float;
    var y:Float;
    var d:Int;
}

typedef Enemy = {
    var x:Float;
    var t:Float;
    var life:Int;
}

typedef Particle = {
    var x:Float;
    var y:Float;
    var t:Float;
}

typedef Bonus = {
    var x:Float;
    var y:Float;
    var b:Int;
}

class Main {
    static function main() {
        var w = window;
        var c:js.html.CanvasElement = cast w.document.querySelector("canvas");
        var screenSize = 512;
        c.width = c.height = screenSize;
        c.style.border = "1px solid black";
        /* var ctx:js.html.CanvasRenderingContext2D = c.getContext("2d"); */
        var ctx:Dynamic = {};
        var lastFireTime:Int;
        var rseed = 0;
        var mx;
        var life:Int;
        var power:Int;
        var mustFire:Bool;
        var bullets:Array<Bullet>;
        var enemies:Array<Enemy>;
        var particles:Array<Particle>;
        var bonuses:Array<Bonus>;
        var time:Int = 0;
        var extremes = [-1, 1];
        var m = Math;
        var abs = m.abs;
        var sin = m.sin;
        var cos = m.cos;
        var state = 0;
        var score;
        var bestScore = 0;
        function random():Float {
            var x = (sin(rseed++) + 1) * 9999;
            return x - Std.int(x);
        }
        w.onmousedown = w.onmouseup = function(e) {
            mustFire = untyped e.buttons;
        }
        w.onmousemove = function(e) {
            mx = 512 - e.clientX;
        }
        function getn(arr:Dynamic) {
            var n = arr.length;

            for(i in 0...n) {
                if(arr[i].t > 666 || abs(arr[i].y) > screenSize*2) {
                    return i;
                }
            }

            return n;
        }
        function fire(x, y, d) {
            bullets[getn(bullets)] = {x:x, y:y, d:d};
        }
        function ftext(a, b, c) {
            ctx.fillText(a, b, c);
        }
        function explode(x, y) {
            for(j in 0...16) {
                particles[getn(particles)] = {x:x, y:y, t:0};
            }

            untyped z(1, .05, 652, 1, .01, .6, 4, 71, .9);
        }
        W.reset(c);
        W.clearColor("#222");
        W.camera({x:256, y:256, z:496, rz:180, fov:27});
        W.light({x:0.5, y:1, z:-0.5});
        W.cube({n:"ship", x:0, y:460, z:0, size:32});
        W.cube({x:0, y:0, z:0, size:10});
        W.cube({x:512, y:0, z:0, size:10});
        W.cube({x:512, y:512, z:0, size:10});
        W.cube({x:0, y:512, z:0, size:10});

        var max_enemies = 16;
        var max_bullets = 48;
        var max_bonuses = 16;
        var max_particles = 64;
        var max_stars = 32;

        for(e in 0...max_enemies) {
            W.cube({n:"e" + e, x:-10000, y:0, z:0, size:32, b:"#922"});
        }

        for(i in 0...max_bullets) {
            W.cube({n:"b" + i, x:-10000, y:0, z:0, h:12, w:4, b:"#aaa"});
        }

        for(i in 0...max_stars) {
            W.sphere({n:"s" + i, size:2});
        }

        for(i in 0...max_particles) {
            W.sphere({n:"p" + i, size:2});
        }

        for(i in 0...max_bonuses) {
            W.sphere({n:"bo" + i, size:6, b:"#2a2"});
        }

        function loop(t:Float) {
            rseed = 1;

            for(i in 0...max_stars) {
                W.move({n:"s"+i, x:(random() * screenSize), y:((random() * screenSize + t * (random() * 0.2)) % screenSize)});
            }

            if(state == 0) {
                /* scale(4); */
                /* ftext("SHIP2k", 24, 32); */
                /* scale(1/2); */
                /* drawShip(200, 160); */
                /* ftext("Click to play!", 42, 232); */
                /* scale(1/2); */
                /* ftext("Best score: " + bestScore, 32, 232); */
                if(mustFire && time > 60) {
                    state++;
                    lastFireTime = time = score = 0;
                    life = 10;
                    power = 1;
                    bullets = [];
                    enemies = [];
                    particles = [];
                    bonuses = [];
                }
            } else if(state == 1) {
                for(i in 0 ... max_bullets) {
                    var b = bullets[i];

                    if(b!=null) {
                        b.y += 10 * b.d;
                        /* col(b.d == -1 ? "#0f0" : "red"); */
                        W.move({n:"b"+i, x:b.x, y:b.y});

                        if(b.d > 0) {
                            if(abs(b.y - 420) + abs(b.x-mx) < 32) {
                                life--;
                                b.y = 999;
                                /* alpha(0.5); */
                                untyped z(1, .05, 918, .8, .04, 0, .2, 24, .6);

                                if(life < 1) {
                                    bestScore = cast m.max(score, bestScore);
                                    state = 0;
                                    time = 0;
                                }
                            }
                        }
                    } else {
                        W.move({n:"b"+i, x:-10000});
                    }
                }

                for(i in 0...max_bonuses) {
                    var b = bonuses[i];

                    if(b != null) {
                        b.y += 3;
                        var hit:Bool = false;

                        if(abs(b.y - 450) + abs(b.x-mx) < 32) {
                            b.y = 999;
                            hit = true;
                        }

                        if(b.b==0) {
                            if(hit) {
                                power++;
                                untyped z(1, .05, 115, .5, .9, .7, .9, 6, .3);
                            }
                        } else {
                            if(hit) {
                                life = cast m.min(life+1, 10);
                                untyped z(1, .05, 1704, .2, .2, .2, .1, 0, .6);
                            }
                        }

                        W.move({n:"bo"+i, x:b.x, y:b.y});
                    } else {
                        W.move({n:"bo"+i, x:-10000 });
                    }
                }

                W.move({n:"ship", x:mx});

                if(mustFire) {
                    if(time - lastFireTime > 15 - power/2) {
                        for(i in 0...cast power/2) {
                            fire((mx) - power*2 + i * 8, 435, -1);
                        }

                        lastFireTime = time;
                        untyped z(1, .05, 1355, .2, .6, .8, .1, .9, .9);
                    }
                }

                for(i in 0...max_particles) {
                    var p = particles[i];

                    if(p != null) {
                        p.t++;
                        var angle = i * 0.174;
                        var v = random() * 3;
                        p.x += cos(angle) * v;
                        p.y += sin(angle) * v;
                        W.move({n:"p"+i, x:p.x, y:p.y});
                    } else {
                        W.move({n:"p"+i, x:-10000 });
                    }
                }

                rseed = time;

                for(i in 0...max_enemies) {
                    var e = enemies[i];

                    if(e != null) {
                        var x = e.x + sin(++e.t / 99) * 99;
                        var y = -64 + e.t;

                        if(e.t % 60 < time/2000) {
                            untyped z(1, .05, 48, .1, .4, 5, 0, 84, .5);
                            fire(x, y, 1);
                        }

                        for(b in bullets) {
                            if(b.d < 0) {
                                if(abs(b.y - y) + abs(b.x-x) < 32) {
                                    b.y = -999;
                                    e.life -= 1;
                                    untyped z(1, .05, 179, .1, .5, 3.5, 1.7, 80, .6);

                                    if(e.life < 1) {
                                        e.t = 666;
                                        score += 100;
                                        explode(x, y);

                                        if(random() < 0.6) {
                                            bonuses[getn(bonuses)] = {x:x, y:y, b:time%2};
                                        }

                                        break;
                                    }
                                }
                            }
                        }

                        W.move({n:"e"+i, x:x, y:y});
                    } else {
                        W.move({n:"e"+i, x:-10000});
                    }
                }

                if((time % 150) < time/2000) {
                    enemies[getn(enemies)] = {x: screenSize * random(), t:0, life:5};
                }

                /* alpha(1); */
                /* col("#222"); */
                /* drawRect(256, 500, screenSize, 24); */
                /* col("#aaf"); */
                /* var str = ""; */
                /* for(i in 0...10) { */
                /*     str += i < life ? untyped ws : untyped bs; */
                /* } */
                /* ftext(str, 12, 506); */
                /* ftext(cast score, 400, 506); */
                /* ftext(cast power, 166, 506); */
            }

            time++;
            w.requestAnimationFrame(loop);
        }
        loop(0);
    }
}
