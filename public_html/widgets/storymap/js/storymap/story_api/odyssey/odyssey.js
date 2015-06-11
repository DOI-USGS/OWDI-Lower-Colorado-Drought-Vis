! function(e) {
    if ("object" == typeof exports && "undefined" != typeof module) module.exports = e();
    else if ("function" == typeof define && define.amd) define([], e);
    else {
        var f;
        "undefined" != typeof window ? f = window : "undefined" != typeof global ? f = global : "undefined" != typeof self && (f = self), f.O = e()
    }
}(function() {
    var define, module, exports;
    return (function e(t, n, r) {
            function s(o, u) {
                if (!n[o]) {
                    if (!t[o]) {
                        var a = typeof require == "function" && require;
                        if (!u && a) return a(o, !0);
                        if (i) return i(o, !0);
                        throw new Error("Cannot find module '" + o + "'")
                    }
                    var f = n[o] = {
                        exports: {}
                    };
                    t[o][0].call(f.exports, function(e) {
                        var n = t[o][1][e];
                        return s(n ? n : e)
                    }, f, f.exports, e, t, n, r)
                }
                return n[o].exports
            }
            var i = typeof require == "function" && require;
            for (var o = 0; o < r.length; o++) s(r[o]);
            return s
        })({
            1: [function(_dereq_, module, exports) {

                var e = _dereq_('./lib/odyssey/story');
                e.Actions = _dereq_('./lib/odyssey/actions');
                e.Triggers = _dereq_('./lib/odyssey/triggers');
                e.Core = _dereq_('./lib/odyssey/core');
                e.UI = _dereq_('./lib/odyssey/ui');
                _dereq_('./lib/odyssey/util');

                for (var k in e.Actions) {
                    e[k] = e.Actions[k];
                }
                for (var k in e.Triggers) {
                    e[k] = e.Triggers[k];
                }
                module.exports = e;

            }, {
                "./lib/odyssey/actions": 5,
                "./lib/odyssey/core": 13,
                "./lib/odyssey/story": 14,
                "./lib/odyssey/triggers": 17,
                "./lib/odyssey/ui": 23,
                "./lib/odyssey/util": 26
            }],
            2: [function(_dereq_, module, exports) {

                var Action = _dereq_('../story').Action;


                function CSS(el) {

                    function _css() {};

                    _css.toggleClass = function(cl) {
                        return Action(function() {
                            el.toggleClass(cl);
                        });
                    };

                    _css.addClass = function(cl) {
                        return Action(function() {
                            el.addClass(cl);
                        });
                    };

                    _css.removeClass = function(cl) {
                        return Action(function() {
                            el.removeClass(cl);
                        });
                    };

                    return _css;

                }

                module.exports = CSS;

            }, {
                "../story": 14
            }],
            3: [function(_dereq_, module, exports) {

                var Action = _dereq_('../story').Action;
                //
                // debug action
                // prints information about current state
                //
                function Debug() {
                    function _debug() {};

                    _debug.log = function(_) {

                        return Action({

                            enter: function() {
                                console.log("STATE =>", _, arguments);
                            },

                            update: function() {
                                console.log("STATE (.)", _, arguments);
                            },

                            exit: function() {
                                console.log("STATE <=", _, arguments);
                            }

                        });

                    };

                    return _debug;
                }

                module.exports = Debug;

            }, {
                "../story": 14
            }],
            4: [function(_dereq_, module, exports) {

                var Action = _dereq_('../story').Action;

                var Audio = function(el) {
                    return {
                        play: function() {
                            return Action(function() {
                                el.play()
                            });
                        },
                        pause: function() {
                            return Action(function() {
                                el.pause()
                            });
                        },
                        setCurrentTime: function(t) {
                            return Action(function() {
                                el.currentTime = t;
                            });
                        }
                    }

                };
                module.exports = Audio;


            }, {
                "../story": 14
            }],
            5: [function(_dereq_, module, exports) {

                module.exports = {
                    Sleep: _dereq_('./sleep'),
                    Debug: _dereq_('./debug'),
                    Location: _dereq_('./location'),
                    Audio: _dereq_('./html5audio'),
                    Leaflet: {
                        Marker: _dereq_('./leaflet/marker'),
                        Map: _dereq_('./leaflet/map'),
                        Popup: _dereq_('./leaflet/popup')
                    },
                    CSS: _dereq_('./css'),
                    Slides: _dereq_('./slides'),
                    MiniProgressBar: _dereq_('./mini_progressbar')
                };

            }, {
                "./css": 2,
                "./debug": 3,
                "./html5audio": 4,
                "./leaflet/map": 6,
                "./leaflet/marker": 7,
                "./leaflet/popup": 8,
                "./location": 9,
                "./mini_progressbar": 10,
                "./sleep": 11,
                "./slides": 12
            }],
            6: [function(_dereq_, module, exports) {

                var Action = _dereq_('../../story').Action;

                function MapActions(map) {

                    function _map() {}

                    // helper method to translate leaflet methods to actions
                    function leaflet_method(name) {
                        _map[name] = function() {
                            var args = arguments;
                            return Action(function() {
                                map[name].apply(map, args);
                            });
                        };
                    }

                    function leaflet_move_method(name, signal) {
                        _map[name] = function() {
                            var args = arguments;
                            return Action({
                                enter: function() {
                                    this.moveEnd = function() {
                                        map.off(signal, this.moveEnd, this);
                                        this.finish();
                                    };
                                    map.on(signal, this.moveEnd, this);
                                    map[name].apply(map, args);
                                    return true;
                                },

                                clear: function() {
                                    map.off(signal, this.moveEnd, this);
                                }
                            });
                        };
                    }

                    _map.moveLinearTo = function(from, to, options) {
                        var opt = options || {
                            k: 2
                        };
                        var animationTimer;
                        var posTarget;
                        var delta = 20;

                        // leaflet map animation is not being used because
                        // when the action is updated the map just stop the animatin
                        // and start again
                        // the animtion should be smooth
                        return Action({

                            enter: function() {
                                posTarget = map.project(map.getCenter());
                                animationTimer = setInterval(function() {
                                    var c = map.project(map.getCenter());
                                    var px = c.x + (posTarget.x - c.x) * delta * 0.001 * opt.k;
                                    var py = c.y + (posTarget.y - c.y) * delta * 0.001 * opt.k;
                                    map.panTo(map.unproject(L.point(px, py)), {
                                        animate: false
                                    });
                                }, delta);
                            },

                            update: function(t) {
                                var p0 = map.project(from);
                                var p1 = map.project(to);
                                posTarget = p0.add(p1.subtract(p0).multiplyBy(t));
                            },

                            exit: function() {
                                clearInterval(animationTimer);
                            },

                            clean: function() {
                                this.exit();
                            }

                        });
                    };


                    // leaflet methods
                    leaflet_move_method('panTo', 'moveend');
                    leaflet_move_method('setView', 'moveend');
                    leaflet_move_method('setZoom', 'zoomend');

                    return _map;
                }


                if (typeof window.L !== 'undefined') {
                    L.Map.addInitHook(function() {
                        this.actions = MapActions(this);
                    });
                }
                module.exports = MapActions;


            }, {
                "../../story": 14
            }],
            7: [function(_dereq_, module, exports) {

                var Action = _dereq_('../../story').Action;

                function MarkerActions(marker) {

                    function _marker() {}

                    _marker.addTo = function(map) {
                        return Action(function() {
                            marker.addTo(map);
                        });
                    };

                    _marker.addRemove = function(map) {
                        return Action({
                            enter: function() {
                                marker.addTo(map);
                            },
                            exit: function() {
                                map.removeLayer(marker);
                            },
                            clear: function() {
                                map.removeLayer(marker);
                            }
                        });
                    };

                    _marker.icon = function(iconEnabled, iconDisabled) {
                        iconEnabled = L.icon({
                            iconUrl: iconEnabled
                        });
                        iconDisabled = L.icon({
                            iconUrl: iconDisabled
                        });
                        return Action({
                            enter: function() {
                                marker.setIcon(iconEnabled);
                            },
                            exit: function() {
                                marker.setIcon(iconDisabled);
                            },
                            clear: function() {}
                        });
                    }

                    return _marker;
                }

                function PathActions(path) {
                    function _path() {};

                    _path.toggleStyle = function(styleDisabled, styleEnabled) {
                        return Action({
                            enter: function() {
                                path.setStyle(styleEnabled);
                            },
                            exit: function() {
                                path.setStyle(styleDisabled);
                            },
                            clear: function() {}
                        });
                    }

                    return _path;
                }


                if (typeof window.L !== 'undefined') {
                    L.Marker.addInitHook(function() {
                        this.actions = MarkerActions(this);
                    });
                    L.Path.addInitHook(function() {
                        this.actions = PathActions(this);
                    })
                }
                module.exports = MarkerActions;

                //marker.actions.addTo(map);
                //addState(, map.actions.moveTo(..).addMarker(m)

            }, {
                "../../story": 14
            }],
            8: [function(_dereq_, module, exports) {

                /**
                directional popup allows to create popups in the left and the right of a point,
                not only on the top.

                Same api than L.popup but you can spcify ``potision`` to 'left' or 'right'

                */

                var Action = _dereq_('../../story').Action;


                if (typeof window.L !== 'undefined') {

                    var DirectionalPopup = L.Popup.extend({
                        _updatePosition: function() {
                            L.Popup.prototype._updatePosition.call(this);
                            var offset = L.point(this.options.offset),
                                animated = this._animated;

                            switch (this.options.position) {
                                case 'left':
                                    this._container.style.bottom = 'auto';
                                    this._container.style.left = 'auto';
                                    this._container.style.right = offset.x + (animated ? 0 : pos.x) + "px";
                                    break;
                                case 'right':
                                    this._container.style.bottom = 'auto';
                                    this._container.style.left = offset.x + "px";
                                    break;
                            }
                        }
                    });

                    L.DirectionalPopup = DirectionalPopup;
                    L.directionalPopup = function(options, source) {
                        return new L.DirectionalPopup(options, source);
                    };

                    function PopupActions(popup) {

                        function _popup() {}

                        // helper method to translate leaflet methods to actions
                        function leaflet_method(name) {
                            _popup[name] = function() {
                                var args = arguments;
                                return Action(function() {
                                    popup[name].apply(popup, args);
                                });
                            };
                        }

                        // leaflet methods
                        leaflet_method('openOn');
                        _popup.openClose = function(map) {
                            if (!map) {
                                throw new Error("openClose gets map as first param");
                            }
                            return Action({
                                enter: function() {
                                    popup.openOn(map);
                                },

                                exit: function() {
                                    map.closePopup(popup);
                                }

                            });
                        };

                        return _popup;
                    }


                    L.Popup.addInitHook(function() {
                        this.actions = PopupActions(this);
                    });
                }


            }, {
                "../../story": 14
            }],
            9: [function(_dereq_, module, exports) {

                var Action = _dereq_('../story').Action;

                var loc = window.location;
                var Location = {

                    // changes the browser url hash
                    changeHash: function(hash) {
                        if (hash === undefined) throw new Error("hash should be a string");
                        return Action(function() {
                            loc.hash = hash;
                        });
                    }

                };


                module.exports = Location;

            }, {
                "../story": 14
            }],
            10: [function(_dereq_, module, exports) {

                var Action = _dereq_('../story').Action;

                /**
                 * mini progress var adds a small line to the top of the browser
                 * and moves according to story progress
                 * usage:
                 * var pg = MiniProgressBar()
                 * story.addAction(trigger, pg.percent(10)) //goes to 10%
                 */

                var MiniProgressBar = function(el) {

                    var defaultStyle = {
                        position: 'fixed',
                        left: 0,
                        top: 0,
                        height: '3px',
                        display: 'inline-block',
                        background: '#ff7373',
                        'z-index': 2
                    };

                    var pg = {};

                    // create an element and apply default style
                    var div = document.createElement('div');
                    div.setAttribute('class', 'oddysey-miniprogressbar');
                    for (var s in defaultStyle) {
                        div.style[s] = defaultStyle[s];
                    }

                    // append to element or to tge body
                    (el || document.body).appendChild(div);

                    /**
                     * returns an action that moves the percentaje bar to the specified one
                     */
                    pg.percent = function(p) {
                        return Action(function() {
                            div.style.width = p + "%";
                        });
                    };

                    return pg;
                }

                module.exports = MiniProgressBar;

            }, {
                "../story": 14
            }],
            11: [function(_dereq_, module, exports) {

                var Action = _dereq_('../story').Action;

                function Sleep(ms) {

                    return Action({

                        enter: function() {
                            setTimeout(this.finish, ms);
                            return true;
                        }

                    });
                }

                module.exports = Sleep;


            }, {
                "../story": 14
            }],
            12: [function(_dereq_, module, exports) {

                var Action = _dereq_('../story').Action;
                var Core = _dereq_('../core');
                var classList = _dereq_('../util/classList');

                function Slides(el) {


                    function slides() {};

                    function _activate(idx) {
                        var slideElements = Core.getElement(el).children;
                        for (var i = 0; i < slideElements.length; ++i) {
                            if (i === idx) {
                                slideElements[i].classList.add("selected", "selected_slide");
                            } else {
                                slideElements[i].classList.remove("selected", "selected_slide");
                            }
                        }
                    }

                    slides.activate = function(i) {
                        return Action(function() {
                            _activate(i);
                        });
                    };

                    _activate(-1);

                    return slides;

                }

                module.exports = Slides;
            }, {
                "../core": 13,
                "../story": 14,
                "../util/classList": 24
            }],
            13: [function(_dereq_, module, exports) {

                function getElement(el) {
                    if (typeof jQuery !== 'undefined') {
                        if (el instanceof jQuery) {
                            return el[0];
                        } else if (typeof el === 'string') {
                            if (el[0] === '#' || el[0] === '.') {
                                return getElement($(el));
                            }
                        }
                    }
                    if (el instanceof NodeList || el instanceof HTMLCollection) {
                        return el[0];
                    } else if (el instanceof Element) {
                        return el;
                    }
                    return document.getElementById(el);
                }

                module.exports = {
                    getElement: getElement
                };

            }, {}],
            14: [function(_dereq_, module, exports) {

                _dereq_('../../vendor/d3.custom');

                function Story() {

                    var triggers = [];
                    var events = [];
                    var currentState = null;
                    var prevState = null;

                    function story(t) {}

                    // event non attached to states
                    story.addEvent = function(trigger, action) {
                        trigger._story(story, function() {
                            action.enter();
                        });
                        events.push({
                            a: trigger,
                            b: action
                        });
                        return story;
                    };

                    story.clear = function() {
                        var all = triggers.concat(events);
                        for (var i = 0; i < all.length; ++i) {
                            var a = all[i];
                            a.a.story = null;
                            a.a.trigger = null;
                            a.a.clear && a.a.clear();
                            a.b.clear && a.b.clear();
                        }

                        triggers = [];
                        events = [];
                        currentState = null;
                        prevState = null;

                    };

                    // go to state index
                    story.go = function(index, opts) {
                        opts = opts || {};
                        if (index < 0 && index > triggers.length) {
                            throw new Error("index should be less than states length");
                        }
                        if (story.state() !== index) {

                            if (opts.reverse) {
                                var a = triggers[index].a;
                                if (a.reverse) {
                                    a.reverse();
                                }
                            }
                            // current state
                            story.state(index);

                            // raise exit
                            if (prevState !== null) {
                                var prev = triggers[prevState].b;
                                if (prev.exit) {
                                    prev.exit();
                                }
                            }

                            var b = triggers[index].b;

                            // enter in current state
                            b.enter();
                        }

                    };

                    story.addState = function(a, b, opts) {
                        var i = triggers.length;

                        if (!a || !b) {
                            throw new Error("action and trigger must be defined");
                        }

                        triggers.push({
                            a: a,
                            b: b,
                            opts: opts
                        });

                        a._story(story, function() {
                            story.go(i);
                        });

                        return story;
                    };

                    story.addLinearState = function(a, b, opts) {
                        var j;
                        var i = triggers.length;

                        triggers.push({
                            a: a,
                            b: b,
                            opts: opts
                        });

                        a._story(story, function(t) {
                            if (story.state() !== i) {
                                story.go(i);
                            } else {
                                if (b.update) {
                                    b.update(t);
                                }
                            }
                        });

                        return story;
                    };

                    story.state = function(_) {
                        if (_ === undefined) return currentState;
                        prevState = currentState;
                        currentState = _;
                        return;
                    };

                    return story;


                }


                //
                // basic action
                // t can be a function or an object
                // if is a function it's called on ``enter`` event
                // if t is an object with enter/exit/update methods
                // they're called on state changes
                function Action(t) {

                    var evt = d3.dispatch('finish');
                    var action = t;
                    if (t.enter === undefined && !(typeof(t) === 'function' && t.prototype.enter !== undefined)) {
                        action = {
                            enter: t
                        }
                    }

                    return d3.rebind(action, evt, 'on', 'finish');

                }

                function Trigger(t) {
                    t = t || {}
                    t._story = function(story, trigger) {
                        this.trigger = trigger;
                        this.story = story;
                    };

                    t.then = function(t, context) {
                        this.trigger = function() {
                            if (t.trigger) {
                                t.trigger();
                                if (t.reverse) t.reverse();
                            } else if (t.call) {
                                t.call(context || self);
                            } else {
                                throw new Error("then first param should be either function or trigger");
                            }
                        };
                    };
                    return t;
                }

                ///
                // executes actions in parallel
                // usage:
                //    Parallel(action1, action2, action3)
                //
                // raises finish when all the tasks has been completed
                //
                function Parallel() {
                    var actions = Array.prototype.slice.call(arguments);
                    var tasksLeft;

                    function _Parallel() {}

                    function start() {
                        tasksLeft = actions.length;
                    }

                    function done() {
                        if (--tasksLeft === 0) {
                            _Parallel.finish();
                        }
                    }

                    function wait(action) {
                        action.on('finish.parallel', function() {
                            action.on('finish.parallel', null);
                            done();
                        });
                    }


                    _Parallel.enter = function() {
                        start();
                        for (var i = 0, len = actions.length; i < len; ++i) {
                            var a = actions[i];
                            if (a.enter) {
                                if (a.enter()) {
                                    wait(a);
                                } else {
                                    done();
                                }
                            }
                        }
                    };

                    _Parallel.exit = function() {
                        start();
                        for (var i = actions.length - 1; i >= 0; --i) {
                            var a = actions[i];
                            if (a.exit) {
                                if (a.exit()) {
                                    wait(a);
                                } else {
                                    done();
                                }
                            }
                        }
                    };

                    _Parallel.clear = function() {
                        for (var i = 0, len = actions.length; i < len; ++i) {
                            var a = actions[i];
                            a.clear && a.clear();
                        }
                    }

                    _Parallel = Action(_Parallel);
                    return _Parallel;
                }



                ///
                // executes actions serially, waits until the previous task
                // is completed to start with the second and so on
                // usage:
                //    Step(action1, action2, action3)
                //
                // raises finish when all the tasks has been completed
                //
                function Step() {

                    var actions = Array.prototype.slice.call(arguments);
                    var queue;

                    function _Step() {}

                    function next(method) {
                        if (queue.length === 0) {
                            _Step.finish();
                            return;
                        }
                        var a = queue.pop();
                        if (a.on) {
                            a.on('finish.chain', function() {
                                a.on('finish.chain', null);
                                next(method);
                            });
                        }
                        if (!a[method] || !a[method]()) {
                            next(method);
                            if (a.on) a.on('finish.chain', null);
                        }
                    }

                    _Step.enter = function() {
                        // call enter on each action
                        queue = actions.slice().reverse();
                        next('enter');
                        return true;
                    }

                    _Step.exit = function() {
                        // call exit on each action
                        queue = actions.slice();
                        next('exit');
                        return true;
                    }

                    _Step.clear = function() {
                        for (var i = 0, len = actions.length; i < len; ++i) {
                            var a = actions[i];
                            a.clear && a.clear();
                        }
                    }

                    _Step = Action(_Step);
                    return _Step;
                }

                // check change between two states and triggers
                function Edge(a, b) {
                    var s = 0;

                    function t() {}
                    a._story(null, function() {
                        if (s !== 0) {
                            t.trigger();
                        }
                        s = 0;
                    });
                    b._story(null, function() {
                        if (s !== 1) {
                            t.trigger();
                        }
                        s = 1;
                    });
                    return Trigger(t);
                }



                module.exports = {
                    Story: Story,
                    Action: Action,
                    Trigger: Trigger,
                    Step: Step,
                    Parallel: Parallel,
                    Edge: Edge
                };


            }, {
                "../../vendor/d3.custom": 32
            }],
            16: [function(_dereq_, module, exports) {

                var Trigger = _dereq_('../story').Trigger;
                var Core = _dereq_('../core');
                var Hammer = _dereq_('hammerjs');

                function Gestures(el) {

                    var gestures = {};
                    el = el || document;

                    function _hammerEvent(eventName, fnName) {
                        gestures[fnName] = function() {
                            var t = Trigger({});
                            Hammer(el).on(eventName, function() {
                                t.trigger();
                            });
                            return t;
                        };
                    }

                    _hammerEvent('swipeup', 'swipeUp');
                    _hammerEvent('swipedown', 'swipeDown');
                    _hammerEvent('swipeleft', 'swipeLeft');
                    _hammerEvent('swiperight', 'swipeRight');

                    return gestures;

                }

                module.exports = Gestures;

            }, {
                "../core": 13,
                "../story": 14,
                "hammerjs": 31
            }],
            17: [function(_dereq_, module, exports) {

                module.exports = {
                    Scroll: _dereq_('./scroll'),
                    Sequential: _dereq_('./sequential'),
                    Keys: _dereq_('./keys'),
                    Video: _dereq_('./video'),
                    Gestures: _dereq_('./gestures')
                };

            }, {
                "./gestures": 16,
                "./keys": 18,
                "./scroll": 19,
                "./sequential": 20,
                "./video": 21
            }],
            18: [function(_dereq_, module, exports) {

                var Trigger = _dereq_('../story').Trigger;
                var Core = _dereq_('../core');

                /**
                 *
                 *
                 */
                function Keys() {

                    KEY_LEFT = 37;
                    KEY_UP = 38;
                    KEY_RIGHT = 39;
                    KEY_DOWN = 40;

                    var el = document;

                    var keys = {};

                    function listenForKey(el, k, callback) {
                        function keyDown(e) {
                            e = e || window.event;

                            var code = e.keyCode;
                            if (code === k) {
                                callback();
                                e.preventDefault ? e.preventDefault() : e.returnValue = false;
                                e.stopPropagation ? e.stopPropagation() : e.cancelBubble = true;
                            }
                        }

                        if (!window.addEventListener) {
                            el.attachEvent("onkeydown", function load(event) {
                                keyDown(event);
                            });
                        } else {
                            el.addEventListener("keydown", function load(event) {
                                keyDown(event);
                            });
                        }
                    }

                    keys.left = function() {
                        var t = Trigger({});
                        listenForKey(el, KEY_LEFT, function() {
                            t.trigger();
                        });
                        return t;
                    }

                    keys.right = function() {
                        var t = Trigger({});
                        listenForKey(el, KEY_RIGHT, function() {
                            t.trigger();
                        });
                        return t;
                    }

                    keys.on = function(element) {
                        el = Core.getElement(element);
                        return keys;
                    }

                    return keys;

                }

                module.exports = Keys;

            }, {
                "../core": 13,
                "../story": 14
            }],
            19: [function(_dereq_, module, exports) {

                var Trigger = _dereq_('../story').Trigger;
                var Core = _dereq_('../core');

                function cte(c) {
                    return function() {
                        return c;
                    }
                }

                //TODO: add support for elements != window
                function Scroll() {

                    var scroller = window;
                    var scrolls = [];
                    var initialized = false;
                    var offset = cte(0);
                    var condition = null;

                    function scroll() {}

                    scroll.reach = function(el) {
                        function _reach() {}
                        Trigger(_reach);

                        _reach.scroll = function(scrollY) {
                            var e = Core.getElement(el);
                            var bounds = e.getBoundingClientRect();
                            var offset = _reach.offset();
                            var t = condition(bounds, offset, scrollY);
                            if (t !== null && t !== undefined) {
                                _reach.trigger(t);
                            }
                            return _reach;
                        };

                        _reach.condition = function(_) {
                            if (!arguments.length) {
                                return condition;
                            }
                            condition = _;
                        }

                        /// sets offset in px or % of element
                        // offset('50%') offset(100)
                        _reach.offset = function(_) {
                            if (!arguments.length) {
                                return offset();
                            }
                            if (typeof(_) === 'number') {
                                offset = cte(_);
                            } else {
                                offset = function() {
                                    //remove %
                                    var percent = +_.replace('%', '');
                                    return scroller.innerHeight * percent * 0.01;
                                }
                            }
                            return _reach;
                        }

                        _reach.reverse = function() {
                            var e = document.getElementById(el);
                            var bounds = e.getBoundingClientRect();
                            var offset = _reach.offset();
                            scroller.scrollTo(0, bounds.top - offset);
                        };

                        _reach.clear = function() {
                            unregister(_reach);
                        }

                        // add to working scrolls
                        register(_reach);

                        return _reach;
                    };

                    scroll.within = function(el) {
                        var r = scroll.reach(el);
                        r.condition(function(bounds, offset) {
                            if (bounds.top <= offset && bounds.bottom >= offset) {
                                var t = (offset - bounds.top) / (bounds.bottom - bounds.top);
                                return t;
                            }
                        });
                        return r;
                    };

                    scroll.less = function(el, opt) {
                        opt = opt || {};
                        var r = scroll.reach(el);
                        var fixedBoundsTop;
                        if (opt.fixed) {
                            var e = Core.getElement(el);
                            fixedBoundsTop = scroller.scrollY + e.getBoundingClientRect().top;
                        }
                        r.condition(function(bounds, offset, scrollY) {
                            var t = opt.fixed ? fixedBoundsTop : bounds.top;
                            var o = opt.fixed ? scrollY : offset;
                            if (t >= o) {
                                return 0;
                            }
                        });
                        return r;
                    };

                    scroll.greater = function(el, opt) {
                        opt = opt || {};
                        var r = scroll.reach(el);
                        var fixedBoundsTop;
                        if (opt.fixed) {
                            var e = Core.getElement(el);
                            fixedBoundsTop = scroller.scrollY + e.getBoundingClientRect().top;
                        }
                        r.condition(function(bounds, offset, scrollY) {
                            var t = opt.fixed ? fixedBoundsTop : bounds.top;
                            var o = opt.fixed ? scrollY : offset;
                            if (t <= o) {
                                return 0;
                            }
                        });
                        return r;
                    };

                    function register(s) {
                        scrolls.push(s);
                        initScroll();
                    }

                    function unregister(s) {
                        var i = scrolls.indexOf(s);
                        if (i >= 0) {
                            scrolls.splice(i, 1);
                        }
                    }

                    function initScroll() {
                        if (!initialized) {
                            initialized = true;

                            if (!Array.prototype.forEach) {

                                Array.prototype.forEach = function(callback, thisArg) {

                                    var T, k;

                                    if (this == null) {
                                        throw new TypeError(" this is null or not defined");
                                    }

                                    // 1. Let O be the result of calling ToObject passing the |this| value as the argument.
                                    var O = Object(this);

                                    // 2. Let lenValue be the result of calling the Get internal method of O with the argument "length".
                                    // 3. Let len be ToUint32(lenValue).
                                    var len = O.length >>> 0;

                                    // 4. If IsCallable(callback) is false, throw a TypeError exception.
                                    // See: http://es5.github.com/#x9.11
                                    if (typeof callback !== "function") {
                                        throw new TypeError(callback + " is not a function");
                                    }

                                    // 5. If thisArg was supplied, let T be thisArg; else let T be undefined.
                                    if (thisArg) {
                                        T = thisArg;
                                    }

                                    // 6. Let k be 0
                                    k = 0;

                                    // 7. Repeat, while k < len
                                    while (k < len) {

                                        var kValue;

                                        // a. Let Pk be ToString(k).
                                        //   This is implicit for LHS operands of the in operator
                                        // b. Let kPresent be the result of calling the HasProperty internal method of O with argument Pk.
                                        //   This step can be combined with c
                                        // c. If kPresent is true, then
                                        if (k in O) {

                                            // i. Let kValue be the result of calling the Get internal method of O with argument Pk.
                                            kValue = O[k];

                                            // ii. Call the Call internal method of callback with T as the this value and
                                            // argument list containing kValue, k, and O.
                                            callback.call(T, kValue, k, O);
                                        }
                                        // d. Increase k by 1.
                                        k++;
                                    }
                                    // 8. return undefined
                                };
                            }

                            function scrollEach() {
                                scrolls.forEach(function(s) {
                                    s.scroll(window.scrollY);
                                });
                            }

                            if (!window.addEventListener) {
                                scroller.attachEvent("onscroll", function load(event) {
                                    scrollEach();
                                });
                            } else {
                                window.addEventListener("scroll", function load(event) {
                                    scrollEach();
                                });
                            }
                        }
                    }

                    return scroll;
                }

                Scroll._scrolls = [];
                module.exports = Scroll;

            }, {
                "../core": 13,
                "../story": 14
            }],
            20: [function(_dereq_, module, exports) {

                var Trigger = _dereq_('../story').Trigger;

                function Sequential() {
                    var current = 0;
                    var steps = [];
                    var max = 0;
                    var triggers = {};

                    function seq() {}

                    function update() {
                        for (var i = 0; i < steps.length; ++i) {
                            steps[i].check();
                        }
                    }

                    seq.state = seq.step = function(n) {
                        if (n in triggers) {
                            return triggers[n];
                        }
                        var t = Trigger({
                            check: function() {
                                if (n === current && this.trigger) this.trigger();
                            },
                            reverse: function() {
                                current = n;
                            }
                        });
                        max = Math.max(max, n);
                        steps.push(t);
                        return triggers[n] = t;
                    };

                    seq.next = function() {
                        current += 1;
                        if (current > max) {
                            current = 0;
                        }
                        update();
                    };

                    seq.clear = function() {
                        steps = [];
                        max = 0;
                        current = 0;
                        return seq;
                    };

                    seq.current = function(_) {
                        if (_ !== undefined) {
                            var c = Math.max(Math.min(max, _), 0);
                            if (c !== current) {
                                current = c;
                                update();
                            }
                            return this;
                        }
                        return current;
                    };

                    seq.prev = function() {
                        current -= 1;
                        if (current < 0) {
                            current = max;
                        }
                        update();
                    };

                    return seq;
                }

                module.exports = Sequential;

            }, {
                "../story": 14
            }],
            21: [function(_dereq_, module, exports) {

                function Video(player) {
                    if (typeof YT === 'undefined' || !(player instanceof YT.Player)) {
                        throw new Error("player should be a YT.Player instance, see youtube API");
                    }

                    var triggers = [];

                    var i = setInterval(function() {
                        var seconds = player.getCurrentTime();
                        for (var i = 0; i < triggers.length; ++i) {
                            var t = triggers[i];
                            if (t.start <= seconds && t.end > seconds) {
                                t.trigger((seconds - t.start) / (t.end - t.start));
                            }
                        }
                    }, 100);

                    var clear = function(t) {
                        if (triggers.length === 0) {
                            clearInterval(i);
                        }
                    };

                    return {
                        between: function(start, end) {
                            var t = O.Trigger();
                            t.start = start;
                            t.end = end;
                            triggers.push(t);
                            t.clear = function() {
                                triggers.splice(triggers.indexOf(t), 1);
                                clear();
                            };
                            return t;
                        }
                    }

                }

                module.exports = Video

            }, {}],
            22: [function(_dereq_, module, exports) {
                /**
                # dot progress
                ui widget that controls dot progress 

                ## usage
                in order to use it you need to instanciate using a container, so for example:

                  <div id="dots"></div>

                  ...

                  var progress = DotProgress('dots')

                  // we set the number of slides
                  progress.count(10);

                  // we can activate it as an action
                  // then the story enters in this state the second dot
                  // will be activated
                  story.addState(trigger, progress.activate(1))

                  // when an user clicks on the dot it can trigger an action
                  story.addState(progress.step(1), action);

                ## styling
                the html rendered is the following:
                ```
                  <div id="dots">
                    <ul>
                      <li><href="#0"></a></li>
                      <li><href="#1" class="active"></a></li>
                      <li><href="#2"></a></li>
                      <li><href="#2"></a></li>
                    </ul>
                  </div>
                ```

                so you can use active class to style the active one
                 
                 */

                var Core = _dereq_('../core');

                function DotProgress(el) {
                    var count = 0;
                    var element = Core.getElement(el);
                    var triggers = {};

                    function _progress() {
                        return _progress;
                    }

                    function render() {
                        var html = '<ul>';
                        for (var i = 0; i < count; ++i) {
                            html += '<li><a slide-index="' + i + '" href="#' + i + '"></a></li>';
                        }
                        html += "</ul>";
                        element.innerHTML = html;
                    }

                    _progress.count = function(_) {
                        count = _;
                        render();
                        return _progress;
                    };

                    // returns an action to activate the index
                    _progress.activate = function(activeIndex) {
                        return O.Action(function() {
                            var children = element.children[0].children;
                            for (var i = 0; i < children.length; ++i) {
                                children[i].children[0].setAttribute('class', '');
                            }
                            children[activeIndex].children[0].setAttribute('class', 'active');
                        });
                    };

                    element.onclick = function(e) {
                        e = e || window.event;

                        var idx = (e.target || e.srcElement).getAttribute('slide-index');
                        var t = triggers[idx];
                        if (t) {
                            t.trigger();
                        }
                    };

                    _progress.step = function(i) {
                        var t = O.Trigger();
                        triggers[i] = t;
                        return t;
                    };

                    return _progress;

                }

                module.exports = DotProgress;

            }, {
                "../core": 13
            }],
            23: [function(_dereq_, module, exports) {

                module.exports = {
                    DotProgress: _dereq_('./dotprogress')
                }

            }, {
                "./dotprogress": 22
            }],
            24: [function(_dereq_, module, exports) {
                /*
                 * classList.js: Cross-browser full element.classList implementation.
                 * 2014-01-31
                 *
                 * By Eli Grey, http://eligrey.com
                 * Public Domain.
                 * NO WARRANTY EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.
                 */

                /*global self, document, DOMException */

                /*! @source http://purl.eligrey.com/github/classList.js/blob/master/classList.js*/

                if ("document" in self && !("classList" in document.createElement("_"))) {

                    (function(view) {

                        "use strict";

                        if (!('Element' in view)) return;

                        var
                            classListProp = "classList",
                            protoProp = "prototype",
                            elemCtrProto = view.Element[protoProp],
                            objCtr = Object,
                            strTrim = String[protoProp].trim || function() {
                                return this.replace(/^\s+|\s+$/g, "");
                            },
                            arrIndexOf = Array[protoProp].indexOf || function(item) {
                                var
                                    i = 0,
                                    len = this.length;
                                for (; i < len; i++) {
                                    if (i in this && this[i] === item) {
                                        return i;
                                    }
                                }
                                return -1;
                            }
                            // Vendors: please allow content code to instantiate DOMExceptions
                            ,
                            DOMEx = function(type, message) {
                                this.name = type;
                                this.code = DOMException[type];
                                this.message = message;
                            },
                            checkTokenAndGetIndex = function(classList, token) {
                                if (token === "") {
                                    throw new DOMEx(
                                        "SYNTAX_ERR", "An invalid or illegal string was specified"
                                    );
                                }
                                if (/\s/.test(token)) {
                                    throw new DOMEx(
                                        "INVALID_CHARACTER_ERR", "String contains an invalid character"
                                    );
                                }
                                return arrIndexOf.call(classList, token);
                            },
                            ClassList = function(elem) {
                                var
                                    trimmedClasses = strTrim.call(elem.getAttribute("class") || ""),
                                    classes = trimmedClasses ? trimmedClasses.split(/\s+/) : [],
                                    i = 0,
                                    len = classes.length;
                                for (; i < len; i++) {
                                    this.push(classes[i]);
                                }
                                this._updateClassName = function() {
                                    elem.setAttribute("class", this.toString());
                                };
                            },
                            classListProto = ClassList[protoProp] = [],
                            classListGetter = function() {
                                return new ClassList(this);
                            };
                        // Most DOMException implementations don't allow calling DOMException's toString()
                        // on non-DOMExceptions. Error's toString() is sufficient here.
                        DOMEx[protoProp] = Error[protoProp];
                        classListProto.item = function(i) {
                            return this[i] || null;
                        };
                        classListProto.contains = function(token) {
                            token += "";
                            return checkTokenAndGetIndex(this, token) !== -1;
                        };
                        classListProto.add = function() {
                            var
                                tokens = arguments,
                                i = 0,
                                l = tokens.length,
                                token, updated = false;
                            do {
                                token = tokens[i] + "";
                                if (checkTokenAndGetIndex(this, token) === -1) {
                                    this.push(token);
                                    updated = true;
                                }
                            }
                            while (++i < l);

                            if (updated) {
                                this._updateClassName();
                            }
                        };
                        classListProto.remove = function() {
                            var
                                tokens = arguments,
                                i = 0,
                                l = tokens.length,
                                token, updated = false;
                            do {
                                token = tokens[i] + "";
                                var index = checkTokenAndGetIndex(this, token);
                                if (index !== -1) {
                                    this.splice(index, 1);
                                    updated = true;
                                }
                            }
                            while (++i < l);

                            if (updated) {
                                this._updateClassName();
                            }
                        };
                        classListProto.toggle = function(token, force) {
                            token += "";

                            var
                                result = this.contains(token),
                                method = result ?
                                force !== true && "remove" :
                                force !== false && "add";

                            if (method) {
                                this[method](token);
                            }

                            return !result;
                        };
                        classListProto.toString = function() {
                            return this.join(" ");
                        };

                        if (objCtr.defineProperty) {
                            var classListPropDesc = {
                                get: classListGetter,
                                enumerable: true,
                                configurable: true
                            };
                            try {
                                objCtr.defineProperty(elemCtrProto, classListProp, classListPropDesc);
                            } catch (ex) { // IE 8 doesn't support enumerable:true
                                if (ex.number === -0x7FF5EC54) {
                                    classListPropDesc.enumerable = false;
                                    objCtr.defineProperty(elemCtrProto, classListProp, classListPropDesc);
                                }
                            }
                        } else if (objCtr[protoProp].__defineGetter__) {
                            elemCtrProto.__defineGetter__(classListProp, classListGetter);
                        }

                    }(self));

                }

            }, {}],
            25: [function(_dereq_, module, exports) {
                /**
                 * new L.CrossHair('http://image.com/image', { x: 10, y :10 }).addTo(map)
                 */
                if (typeof window.L !== 'undefined') {

                    L.CrossHair = L.Control.extend({

                        initialize: function(img, size) {
                            this.image = new Image();
                            this.image.onload = L.bind(this._updatePos, this);
                            this.image.src = img;
                            if (size) {
                                this.image.width = size.x;
                                this.image.height = size.y;
                            }
                        },

                        _updatePos: function() {
                            if (this._map) {
                                var w = this.image.width >> 1;
                                var h = this.image.height >> 1;
                                w = this._map.getSize().x / 2.0 - w;
                                h = this._map.getSize().y / 2.0 - h;
                                L.DomUtil.setPosition(this.image, {
                                    x: w,
                                    y: h
                                });
                            }
                        },

                        addTo: function(map) {
                            var r = L.Control.prototype.addTo.call(this, map);
                            // remove leaflet-top and leaflet-right classes
                            this.image.parentNode.setAttribute('class', '');
                            map.on('resize', L.bind(this._updatePos, this));
                            return r;
                        },

                        onRemove: function(map) {
                            map.off('resize', null, this);
                        },

                        onAdd: function(map) {
                            this._updatePos();
                            return this.image;
                        }

                    });

                }

            }, {}],
            26: [function(_dereq_, module, exports) {

                module.exports = {
                    CrossHair: _dereq_('./crosshair')
                }

            }, {
                "./crosshair": 25
            }],
            27: [function(_dereq_, module, exports) {
                if (typeof Object.create === 'function') {
                    // implementation from standard node.js 'util' module
                    module.exports = function inherits(ctor, superCtor) {
                        ctor.super_ = superCtor
                        ctor.prototype = Object.create(superCtor.prototype, {
                            constructor: {
                                value: ctor,
                                enumerable: false,
                                writable: true,
                                configurable: true
                            }
                        });
                    };
                } else {
                    // old school shim for old browsers
                    module.exports = function inherits(ctor, superCtor) {
                        ctor.super_ = superCtor
                        var TempCtor = function() {}
                        TempCtor.prototype = superCtor.prototype
                        ctor.prototype = new TempCtor()
                        ctor.prototype.constructor = ctor
                    }
                }

            }, {}],
            28: [function(_dereq_, module, exports) {
                // shim for using process in browser

                var process = module.exports = {};

                process.nextTick = (function() {
                    var canSetImmediate = typeof window !== 'undefined' && window.setImmediate;
                    var canPost = typeof window !== 'undefined' && window.postMessage && window.addEventListener;

                    if (canSetImmediate) {
                        return function(f) {
                            return window.setImmediate(f)
                        };
                    }

                    if (canPost) {
                        var queue = [];
                        window.addEventListener('message', function(ev) {
                            var source = ev.source;
                            if ((source === window || source === null) && ev.data === 'process-tick') {
                                ev.stopPropagation();
                                if (queue.length > 0) {
                                    var fn = queue.shift();
                                    fn();
                                }
                            }
                        }, true);

                        return function nextTick(fn) {
                            queue.push(fn);
                            window.postMessage('process-tick', '*');
                        };
                    }

                    return function nextTick(fn) {
                        setTimeout(fn, 0);
                    };
                })();

                process.title = 'browser';
                process.browser = true;
                process.env = {};
                process.argv = [];

                function noop() {}

                process.on = noop;
                process.addListener = noop;
                process.once = noop;
                process.off = noop;
                process.removeListener = noop;
                process.removeAllListeners = noop;
                process.emit = noop;

                process.binding = function(name) {
                    throw new Error('process.binding is not supported');
                }

                // TODO(shtylman)
                process.cwd = function() {
                    return '/'
                };
                process.chdir = function(dir) {
                    throw new Error('process.chdir is not supported');
                };

            }, {}],
            29: [function(_dereq_, module, exports) {
                module.exports = function isBuffer(arg) {
                    return arg && typeof arg === 'object' && typeof arg.copy === 'function' && typeof arg.fill === 'function' && typeof arg.readUInt8 === 'function';
                }
            }, {}],
            30: [function(_dereq_, module, exports) {
                (function(process, global) {
                    // Copyright Joyent, Inc. and other Node contributors.
                    //
                    // Permission is hereby granted, free of charge, to any person obtaining a
                    // copy of this software and associated documentation files (the
                    // "Software"), to deal in the Software without restriction, including
                    // without limitation the rights to use, copy, modify, merge, publish,
                    // distribute, sublicense, and/or sell copies of the Software, and to permit
                    // persons to whom the Software is furnished to do so, subject to the
                    // following conditions:
                    //
                    // The above copyright notice and this permission notice shall be included
                    // in all copies or substantial portions of the Software.
                    //
                    // THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
                    // OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
                    // MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
                    // NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
                    // DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
                    // OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
                    // USE OR OTHER DEALINGS IN THE SOFTWARE.

                    var formatRegExp = /%[sdj%]/g;
                    exports.format = function(f) {
                        if (!isString(f)) {
                            var objects = [];
                            for (var i = 0; i < arguments.length; i++) {
                                objects.push(inspect(arguments[i]));
                            }
                            return objects.join(' ');
                        }

                        var i = 1;
                        var args = arguments;
                        var len = args.length;
                        var str = String(f).replace(formatRegExp, function(x) {
                            if (x === '%%') return '%';
                            if (i >= len) return x;
                            switch (x) {
                                case '%s':
                                    return String(args[i++]);
                                case '%d':
                                    return Number(args[i++]);
                                case '%j':
                                    try {
                                        return JSON.stringify(args[i++]);
                                    } catch (_) {
                                        return '[Circular]';
                                    }
                                default:
                                    return x;
                            }
                        });
                        for (var x = args[i]; i < len; x = args[++i]) {
                            if (isNull(x) || !isObject(x)) {
                                str += ' ' + x;
                            } else {
                                str += ' ' + inspect(x);
                            }
                        }
                        return str;
                    };


                    // Mark that a method should not be used.
                    // Returns a modified function which warns once by default.
                    // If --no-deprecation is set, then it is a no-op.
                    exports.deprecate = function(fn, msg) {
                        // Allow for deprecating things in the process of starting up.
                        if (isUndefined(global.process)) {
                            return function() {
                                return exports.deprecate(fn, msg).apply(this, arguments);
                            };
                        }

                        if (process.noDeprecation === true) {
                            return fn;
                        }

                        var warned = false;

                        function deprecated() {
                            if (!warned) {
                                if (process.throwDeprecation) {
                                    throw new Error(msg);
                                } else if (process.traceDeprecation) {
                                    console.trace(msg);
                                } else {
                                    console.error(msg);
                                }
                                warned = true;
                            }
                            return fn.apply(this, arguments);
                        }

                        return deprecated;
                    };


                    var debugs = {};
                    var debugEnviron;
                    exports.debuglog = function(set) {
                        if (isUndefined(debugEnviron))
                            debugEnviron = process.env.NODE_DEBUG || '';
                        set = set.toUpperCase();
                        if (!debugs[set]) {
                            if (new RegExp('\\b' + set + '\\b', 'i').test(debugEnviron)) {
                                var pid = process.pid;
                                debugs[set] = function() {
                                    var msg = exports.format.apply(exports, arguments);
                                    console.error('%s %d: %s', set, pid, msg);
                                };
                            } else {
                                debugs[set] = function() {};
                            }
                        }
                        return debugs[set];
                    };


                    /**
                     * Echos the value of a value. Trys to print the value out
                     * in the best way possible given the different types.
                     *
                     * @param {Object} obj The object to print out.
                     * @param {Object} opts Optional options object that alters the output.
                     */
                    /* legacy: obj, showHidden, depth, colors*/
                    function inspect(obj, opts) {
                        // default options
                        var ctx = {
                            seen: [],
                            stylize: stylizeNoColor
                        };
                        // legacy...
                        if (arguments.length >= 3) ctx.depth = arguments[2];
                        if (arguments.length >= 4) ctx.colors = arguments[3];
                        if (isBoolean(opts)) {
                            // legacy...
                            ctx.showHidden = opts;
                        } else if (opts) {
                            // got an "options" object
                            exports._extend(ctx, opts);
                        }
                        // set default options
                        if (isUndefined(ctx.showHidden)) ctx.showHidden = false;
                        if (isUndefined(ctx.depth)) ctx.depth = 2;
                        if (isUndefined(ctx.colors)) ctx.colors = false;
                        if (isUndefined(ctx.customInspect)) ctx.customInspect = true;
                        if (ctx.colors) ctx.stylize = stylizeWithColor;
                        return formatValue(ctx, obj, ctx.depth);
                    }
                    exports.inspect = inspect;


                    // http://en.wikipedia.org/wiki/ANSI_escape_code#graphics
                    inspect.colors = {
                        'bold': [1, 22],
                        'italic': [3, 23],
                        'underline': [4, 24],
                        'inverse': [7, 27],
                        'white': [37, 39],
                        'grey': [90, 39],
                        'black': [30, 39],
                        'blue': [34, 39],
                        'cyan': [36, 39],
                        'green': [32, 39],
                        'magenta': [35, 39],
                        'red': [31, 39],
                        'yellow': [33, 39]
                    };

                    // Don't use 'blue' not visible on cmd.exe
                    inspect.styles = {
                        'special': 'cyan',
                        'number': 'yellow',
                        'boolean': 'yellow',
                        'undefined': 'grey',
                        'null': 'bold',
                        'string': 'green',
                        'date': 'magenta',
                        // "name": intentionally not styling
                        'regexp': 'red'
                    };


                    function stylizeWithColor(str, styleType) {
                        var style = inspect.styles[styleType];

                        if (style) {
                            return '\u001b[' + inspect.colors[style][0] + 'm' + str +
                                '\u001b[' + inspect.colors[style][1] + 'm';
                        } else {
                            return str;
                        }
                    }


                    function stylizeNoColor(str, styleType) {
                        return str;
                    }


                    function arrayToHash(array) {
                        var hash = {};

                        array.forEach(function(val, idx) {
                            hash[val] = true;
                        });

                        return hash;
                    }


                    function formatValue(ctx, value, recurseTimes) {
                        // Provide a hook for user-specified inspect functions.
                        // Check that value is an object with an inspect function on it
                        if (ctx.customInspect &&
                            value &&
                            isFunction(value.inspect) &&
                            // Filter out the util module, it's inspect function is special
                            value.inspect !== exports.inspect &&
                            // Also filter out any prototype objects using the circular check.
                            !(value.constructor && value.constructor.prototype === value)) {
                            var ret = value.inspect(recurseTimes, ctx);
                            if (!isString(ret)) {
                                ret = formatValue(ctx, ret, recurseTimes);
                            }
                            return ret;
                        }

                        // Primitive types cannot have properties
                        var primitive = formatPrimitive(ctx, value);
                        if (primitive) {
                            return primitive;
                        }

                        // Look up the keys of the object.
                        var keys = Object.keys(value);
                        var visibleKeys = arrayToHash(keys);

                        if (ctx.showHidden) {
                            keys = Object.getOwnPropertyNames(value);
                        }

                        // IE doesn't make error fields non-enumerable
                        // http://msdn.microsoft.com/en-us/library/ie/dww52sbt(v=vs.94).aspx
                        if (isError(value) && (keys.indexOf('message') >= 0 || keys.indexOf('description') >= 0)) {
                            return formatError(value);
                        }

                        // Some type of object without properties can be shortcutted.
                        if (keys.length === 0) {
                            if (isFunction(value)) {
                                var name = value.name ? ': ' + value.name : '';
                                return ctx.stylize('[Function' + name + ']', 'special');
                            }
                            if (isRegExp(value)) {
                                return ctx.stylize(RegExp.prototype.toString.call(value), 'regexp');
                            }
                            if (isDate(value)) {
                                return ctx.stylize(Date.prototype.toString.call(value), 'date');
                            }
                            if (isError(value)) {
                                return formatError(value);
                            }
                        }

                        var base = '',
                            array = false,
                            braces = ['{', '}'];

                        // Make Array say that they are Array
                        if (isArray(value)) {
                            array = true;
                            braces = ['[', ']'];
                        }

                        // Make functions say that they are functions
                        if (isFunction(value)) {
                            var n = value.name ? ': ' + value.name : '';
                            base = ' [Function' + n + ']';
                        }

                        // Make RegExps say that they are RegExps
                        if (isRegExp(value)) {
                            base = ' ' + RegExp.prototype.toString.call(value);
                        }

                        // Make dates with properties first say the date
                        if (isDate(value)) {
                            base = ' ' + Date.prototype.toUTCString.call(value);
                        }

                        // Make error with message first say the error
                        if (isError(value)) {
                            base = ' ' + formatError(value);
                        }

                        if (keys.length === 0 && (!array || value.length == 0)) {
                            return braces[0] + base + braces[1];
                        }

                        if (recurseTimes < 0) {
                            if (isRegExp(value)) {
                                return ctx.stylize(RegExp.prototype.toString.call(value), 'regexp');
                            } else {
                                return ctx.stylize('[Object]', 'special');
                            }
                        }

                        ctx.seen.push(value);

                        var output;
                        if (array) {
                            output = formatArray(ctx, value, recurseTimes, visibleKeys, keys);
                        } else {
                            output = keys.map(function(key) {
                                return formatProperty(ctx, value, recurseTimes, visibleKeys, key, array);
                            });
                        }

                        ctx.seen.pop();

                        return reduceToSingleString(output, base, braces);
                    }


                    function formatPrimitive(ctx, value) {
                        if (isUndefined(value))
                            return ctx.stylize('undefined', 'undefined');
                        if (isString(value)) {
                            var simple = '\'' + JSON.stringify(value).replace(/^"|"$/g, '')
                                .replace(/'/g, "\\'")
                                .replace(/\\"/g, '"') + '\'';
                            return ctx.stylize(simple, 'string');
                        }
                        if (isNumber(value))
                            return ctx.stylize('' + value, 'number');
                        if (isBoolean(value))
                            return ctx.stylize('' + value, 'boolean');
                        // For some reason typeof null is "object", so special case here.
                        if (isNull(value))
                            return ctx.stylize('null', 'null');
                    }


                    function formatError(value) {
                        return '[' + Error.prototype.toString.call(value) + ']';
                    }


                    function formatArray(ctx, value, recurseTimes, visibleKeys, keys) {
                        var output = [];
                        for (var i = 0, l = value.length; i < l; ++i) {
                            if (hasOwnProperty(value, String(i))) {
                                output.push(formatProperty(ctx, value, recurseTimes, visibleKeys,
                                    String(i), true));
                            } else {
                                output.push('');
                            }
                        }
                        keys.forEach(function(key) {
                            if (!key.match(/^\d+$/)) {
                                output.push(formatProperty(ctx, value, recurseTimes, visibleKeys,
                                    key, true));
                            }
                        });
                        return output;
                    }


                    function formatProperty(ctx, value, recurseTimes, visibleKeys, key, array) {
                        var name, str, desc;
                        desc = Object.getOwnPropertyDescriptor(value, key) || {
                            value: value[key]
                        };
                        if (desc.get) {
                            if (desc.set) {
                                str = ctx.stylize('[Getter/Setter]', 'special');
                            } else {
                                str = ctx.stylize('[Getter]', 'special');
                            }
                        } else {
                            if (desc.set) {
                                str = ctx.stylize('[Setter]', 'special');
                            }
                        }
                        if (!hasOwnProperty(visibleKeys, key)) {
                            name = '[' + key + ']';
                        }
                        if (!str) {
                            if (ctx.seen.indexOf(desc.value) < 0) {
                                if (isNull(recurseTimes)) {
                                    str = formatValue(ctx, desc.value, null);
                                } else {
                                    str = formatValue(ctx, desc.value, recurseTimes - 1);
                                }
                                if (str.indexOf('\n') > -1) {
                                    if (array) {
                                        str = str.split('\n').map(function(line) {
                                            return '  ' + line;
                                        }).join('\n').substr(2);
                                    } else {
                                        str = '\n' + str.split('\n').map(function(line) {
                                            return '   ' + line;
                                        }).join('\n');
                                    }
                                }
                            } else {
                                str = ctx.stylize('[Circular]', 'special');
                            }
                        }
                        if (isUndefined(name)) {
                            if (array && key.match(/^\d+$/)) {
                                return str;
                            }
                            name = JSON.stringify('' + key);
                            if (name.match(/^"([a-zA-Z_][a-zA-Z_0-9]*)"$/)) {
                                name = name.substr(1, name.length - 2);
                                name = ctx.stylize(name, 'name');
                            } else {
                                name = name.replace(/'/g, "\\'")
                                    .replace(/\\"/g, '"')
                                    .replace(/(^"|"$)/g, "'");
                                name = ctx.stylize(name, 'string');
                            }
                        }

                        return name + ': ' + str;
                    }


                    function reduceToSingleString(output, base, braces) {
                        var numLinesEst = 0;
                        var length = output.reduce(function(prev, cur) {
                            numLinesEst++;
                            if (cur.indexOf('\n') >= 0) numLinesEst++;
                            return prev + cur.replace(/\u001b\[\d\d?m/g, '').length + 1;
                        }, 0);

                        if (length > 60) {
                            return braces[0] +
                                (base === '' ? '' : base + '\n ') +
                                ' ' +
                                output.join(',\n  ') +
                                ' ' +
                                braces[1];
                        }

                        return braces[0] + base + ' ' + output.join(', ') + ' ' + braces[1];
                    }


                    // NOTE: These type checking functions intentionally don't use `instanceof`
                    // because it is fragile and can be easily faked with `Object.create()`.
                    function isArray(ar) {
                        return Array.isArray(ar);
                    }
                    exports.isArray = isArray;

                    function isBoolean(arg) {
                        return typeof arg === 'boolean';
                    }
                    exports.isBoolean = isBoolean;

                    function isNull(arg) {
                        return arg === null;
                    }
                    exports.isNull = isNull;

                    function isNullOrUndefined(arg) {
                        return arg == null;
                    }
                    exports.isNullOrUndefined = isNullOrUndefined;

                    function isNumber(arg) {
                        return typeof arg === 'number';
                    }
                    exports.isNumber = isNumber;

                    function isString(arg) {
                        return typeof arg === 'string';
                    }
                    exports.isString = isString;

                    function isSymbol(arg) {
                        return typeof arg === 'symbol';
                    }
                    exports.isSymbol = isSymbol;

                    function isUndefined(arg) {
                        return arg === void 0;
                    }
                    exports.isUndefined = isUndefined;

                    function isRegExp(re) {
                        return isObject(re) && objectToString(re) === '[object RegExp]';
                    }
                    exports.isRegExp = isRegExp;

                    function isObject(arg) {
                        return typeof arg === 'object' && arg !== null;
                    }
                    exports.isObject = isObject;

                    function isDate(d) {
                        return isObject(d) && objectToString(d) === '[object Date]';
                    }
                    exports.isDate = isDate;

                    function isError(e) {
                        return isObject(e) &&
                            (objectToString(e) === '[object Error]' || e instanceof Error);
                    }
                    exports.isError = isError;

                    function isFunction(arg) {
                        return typeof arg === 'function';
                    }
                    exports.isFunction = isFunction;

                    function isPrimitive(arg) {
                        return arg === null ||
                            typeof arg === 'boolean' ||
                            typeof arg === 'number' ||
                            typeof arg === 'string' ||
                            typeof arg === 'symbol' || // ES6 symbol
                            typeof arg === 'undefined';
                    }
                    exports.isPrimitive = isPrimitive;

                    exports.isBuffer = _dereq_('./support/isBuffer');

                    function objectToString(o) {
                        return Object.prototype.toString.call(o);
                    }


                    function pad(n) {
                        return n < 10 ? '0' + n.toString(10) : n.toString(10);
                    }


                    var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep',
                        'Oct', 'Nov', 'Dec'
                    ];

                    // 26 Feb 16:19:34
                    function timestamp() {
                        var d = new Date();
                        var time = [pad(d.getHours()),
                            pad(d.getMinutes()),
                            pad(d.getSeconds())
                        ].join(':');
                        return [d.getDate(), months[d.getMonth()], time].join(' ');
                    }


                    // log is just a thin wrapper to console.log that prepends a timestamp
                    exports.log = function() {
                        console.log('%s - %s', timestamp(), exports.format.apply(exports, arguments));
                    };


                    /**
                     * Inherit the prototype methods from one constructor into another.
                     *
                     * The Function.prototype.inherits from lang.js rewritten as a standalone
                     * function (not on Function.prototype). NOTE: If this file is to be loaded
                     * during bootstrapping this function needs to be rewritten using some native
                     * functions as prototype setup using normal JavaScript does not work as
                     * expected during bootstrapping (see mirror.js in r114903).
                     *
                     * @param {function} ctor Constructor function which needs to inherit the
                     *     prototype.
                     * @param {function} superCtor Constructor function to inherit prototype from.
                     */
                    exports.inherits = _dereq_('inherits');

                    exports._extend = function(origin, add) {
                        // Don't do anything if add isn't an object
                        if (!add || !isObject(add)) return origin;

                        var keys = Object.keys(add);
                        var i = keys.length;
                        while (i--) {
                            origin[keys[i]] = add[keys[i]];
                        }
                        return origin;
                    };

                    function hasOwnProperty(obj, prop) {
                        return Object.prototype.hasOwnProperty.call(obj, prop);
                    }

                }).call(this, _dereq_("FWaASH"), typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
            }, {
                "./support/isBuffer": 29,
                "FWaASH": 28,
                "inherits": 27
            }],
            31: [function(_dereq_, module, exports) {
                /*! Hammer.JS - v1.1.3 - 2014-05-20
                 * http://eightmedia.github.io/hammer.js
                 *
                 * Copyright (c) 2014 Jorik Tangelder <j.tangelder@gmail.com>;
                 * Licensed under the MIT license */

                (function(window, undefined) {
                    'use strict';

                    /**
                     * @main
                     * @module hammer
                     *
                     * @class Hammer
                     * @static
                     */

                    /**
                     * Hammer, use this to create instances
                     * ````
                     * var hammertime = new Hammer(myElement);
                     * ````
                     *
                     * @method Hammer
                     * @param {HTMLElement} element
                     * @param {Object} [options={}]
                     * @return {Hammer.Instance}
                     */
                    var Hammer = function Hammer(element, options) {
                        return new Hammer.Instance(element, options || {});
                    };

                    /**
                     * version, as defined in package.json
                     * the value will be set at each build
                     * @property VERSION
                     * @final
                     * @type {String}
                     */
                    Hammer.VERSION = '1.1.3';

                    /**
                     * default settings.
                     * more settings are defined per gesture at `/gestures`. Each gesture can be disabled/enabled
                     * by setting it's name (like `swipe`) to false.
                     * You can set the defaults for all instances by changing this object before creating an instance.
                     * @example
                     * ````
                     *  Hammer.defaults.drag = false;
                     *  Hammer.defaults.behavior.touchAction = 'pan-y';
                     *  delete Hammer.defaults.behavior.userSelect;
                     * ````
                     * @property defaults
                     * @type {Object}
                     */
                    Hammer.defaults = {
                        /**
                         * this setting object adds styles and attributes to the element to prevent the browser from doing
                         * its native behavior. The css properties are auto prefixed for the browsers when needed.
                         * @property defaults.behavior
                         * @type {Object}
                         */
                        behavior: {
                            /**
                             * Disables text selection to improve the dragging gesture. When the value is `none` it also sets
                             * `onselectstart=false` for IE on the element. Mainly for desktop browsers.
                             * @property defaults.behavior.userSelect
                             * @type {String}
                             * @default 'none'
                             */
                            userSelect: 'none',

                            /**
                             * Specifies whether and how a given region can be manipulated by the user (for instance, by panning or zooming).
                             * Used by Chrome 35> and IE10>. By default this makes the element blocking any touch event.
                             * @property defaults.behavior.touchAction
                             * @type {String}
                             * @default: 'pan-y'
                             */
                            touchAction: 'pan-y',

                            /**
                             * Disables the default callout shown when you touch and hold a touch target.
                             * On iOS, when you touch and hold a touch target such as a link, Safari displays
                             * a callout containing information about the link. This property allows you to disable that callout.
                             * @property defaults.behavior.touchCallout
                             * @type {String}
                             * @default 'none'
                             */
                            touchCallout: 'none',

                            /**
                             * Specifies whether zooming is enabled. Used by IE10>
                             * @property defaults.behavior.contentZooming
                             * @type {String}
                             * @default 'none'
                             */
                            contentZooming: 'none',

                            /**
                             * Specifies that an entire element should be draggable instead of its contents.
                             * Mainly for desktop browsers.
                             * @property defaults.behavior.userDrag
                             * @type {String}
                             * @default 'none'
                             */
                            userDrag: 'none',

                            /**
                             * Overrides the highlight color shown when the user taps a link or a JavaScript
                             * clickable element in Safari on iPhone. This property obeys the alpha value, if specified.
                             *
                             * If you don't specify an alpha value, Safari on iPhone applies a default alpha value
                             * to the color. To disable tap highlighting, set the alpha value to 0 (invisible).
                             * If you set the alpha value to 1.0 (opaque), the element is not visible when tapped.
                             * @property defaults.behavior.tapHighlightColor
                             * @type {String}
                             * @default 'rgba(0,0,0,0)'
                             */
                            tapHighlightColor: 'rgba(0,0,0,0)'
                        }
                    };

                    /**
                     * hammer document where the base events are added at
                     * @property DOCUMENT
                     * @type {HTMLElement}
                     * @default window.document
                     */
                    Hammer.DOCUMENT = document;

                    /**
                     * detect support for pointer events
                     * @property HAS_POINTEREVENTS
                     * @type {Boolean}
                     */
                    Hammer.HAS_POINTEREVENTS = navigator.pointerEnabled || navigator.msPointerEnabled;

                    /**
                     * detect support for touch events
                     * @property HAS_TOUCHEVENTS
                     * @type {Boolean}
                     */
                    Hammer.HAS_TOUCHEVENTS = ('ontouchstart' in window);

                    /**
                     * detect mobile browsers
                     * @property IS_MOBILE
                     * @type {Boolean}
                     */
                    Hammer.IS_MOBILE = /mobile|tablet|ip(ad|hone|od)|android|silk/i.test(navigator.userAgent);

                    /**
                     * detect if we want to support mouseevents at all
                     * @property NO_MOUSEEVENTS
                     * @type {Boolean}
                     */
                    Hammer.NO_MOUSEEVENTS = (Hammer.HAS_TOUCHEVENTS && Hammer.IS_MOBILE) || Hammer.HAS_POINTEREVENTS;

                    /**
                     * interval in which Hammer recalculates current velocity/direction/angle in ms
                     * @property CALCULATE_INTERVAL
                     * @type {Number}
                     * @default 25
                     */
                    Hammer.CALCULATE_INTERVAL = 25;

                    /**
                     * eventtypes per touchevent (start, move, end) are filled by `Event.determineEventTypes` on `setup`
                     * the object contains the DOM event names per type (`EVENT_START`, `EVENT_MOVE`, `EVENT_END`)
                     * @property EVENT_TYPES
                     * @private
                     * @writeOnce
                     * @type {Object}
                     */
                    var EVENT_TYPES = {};

                    /**
                     * direction strings, for safe comparisons
                     * @property DIRECTION_DOWN|LEFT|UP|RIGHT
                     * @final
                     * @type {String}
                     * @default 'down' 'left' 'up' 'right'
                     */
                    var DIRECTION_DOWN = Hammer.DIRECTION_DOWN = 'down';
                    var DIRECTION_LEFT = Hammer.DIRECTION_LEFT = 'left';
                    var DIRECTION_UP = Hammer.DIRECTION_UP = 'up';
                    var DIRECTION_RIGHT = Hammer.DIRECTION_RIGHT = 'right';

                    /**
                     * pointertype strings, for safe comparisons
                     * @property POINTER_MOUSE|TOUCH|PEN
                     * @final
                     * @type {String}
                     * @default 'mouse' 'touch' 'pen'
                     */
                    var POINTER_MOUSE = Hammer.POINTER_MOUSE = 'mouse';
                    var POINTER_TOUCH = Hammer.POINTER_TOUCH = 'touch';
                    var POINTER_PEN = Hammer.POINTER_PEN = 'pen';

                    /**
                     * eventtypes
                     * @property EVENT_START|MOVE|END|RELEASE|TOUCH
                     * @final
                     * @type {String}
                     * @default 'start' 'change' 'move' 'end' 'release' 'touch'
                     */
                    var EVENT_START = Hammer.EVENT_START = 'start';
                    var EVENT_MOVE = Hammer.EVENT_MOVE = 'move';
                    var EVENT_END = Hammer.EVENT_END = 'end';
                    var EVENT_RELEASE = Hammer.EVENT_RELEASE = 'release';
                    var EVENT_TOUCH = Hammer.EVENT_TOUCH = 'touch';

                    /**
                     * if the window events are set...
                     * @property READY
                     * @writeOnce
                     * @type {Boolean}
                     * @default false
                     */
                    Hammer.READY = false;

                    /**
                     * plugins namespace
                     * @property plugins
                     * @type {Object}
                     */
                    Hammer.plugins = Hammer.plugins || {};

                    /**
                     * gestures namespace
                     * see `/gestures` for the definitions
                     * @property gestures
                     * @type {Object}
                     */
                    Hammer.gestures = Hammer.gestures || {};

                    /**
                     * setup events to detect gestures on the document
                     * this function is called when creating an new instance
                     * @private
                     */
                    function setup() {
                        if (Hammer.READY) {
                            return;
                        }

                        // find what eventtypes we add listeners to
                        Event.determineEventTypes();

                        // Register all gestures inside Hammer.gestures
                        Utils.each(Hammer.gestures, function(gesture) {
                            Detection.register(gesture);
                        });

                        // Add touch events on the document
                        Event.onTouch(Hammer.DOCUMENT, EVENT_MOVE, Detection.detect);
                        Event.onTouch(Hammer.DOCUMENT, EVENT_END, Detection.detect);

                        // Hammer is ready...!
                        Hammer.READY = true;
                    }

                    /**
                     * @module hammer
                     *
                     * @class Utils
                     * @static
                     */
                    var Utils = Hammer.utils = {
                        /**
                         * extend method, could also be used for cloning when `dest` is an empty object.
                         * changes the dest object
                         * @method extend
                         * @param {Object} dest
                         * @param {Object} src
                         * @param {Boolean} [merge=false]  do a merge
                         * @return {Object} dest
                         */
                        extend: function extend(dest, src, merge) {
                            for (var key in src) {
                                if (!src.hasOwnProperty(key) || (dest[key] !== undefined && merge)) {
                                    continue;
                                }
                                dest[key] = src[key];
                            }
                            return dest;
                        },

                        /**
                         * simple addEventListener wrapper
                         * @method on
                         * @param {HTMLElement} element
                         * @param {String} type
                         * @param {Function} handler
                         */
                        on: function on(element, type, handler) {
                            element.addEventListener(type, handler, false);
                        },

                        /**
                         * simple removeEventListener wrapper
                         * @method off
                         * @param {HTMLElement} element
                         * @param {String} type
                         * @param {Function} handler
                         */
                        off: function off(element, type, handler) {
                            element.removeEventListener(type, handler, false);
                        },

                        /**
                         * forEach over arrays and objects
                         * @method each
                         * @param {Object|Array} obj
                         * @param {Function} iterator
                         * @param {any} iterator.item
                         * @param {Number} iterator.index
                         * @param {Object|Array} iterator.obj the source object
                         * @param {Object} context value to use as `this` in the iterator
                         */
                        each: function each(obj, iterator, context) {
                            var i, len;

                            // native forEach on arrays
                            if ('forEach' in obj) {
                                obj.forEach(iterator, context);
                                // arrays
                            } else if (obj.length !== undefined) {
                                for (i = 0, len = obj.length; i < len; i++) {
                                    if (iterator.call(context, obj[i], i, obj) === false) {
                                        return;
                                    }
                                }
                                // objects
                            } else {
                                for (i in obj) {
                                    if (obj.hasOwnProperty(i) &&
                                        iterator.call(context, obj[i], i, obj) === false) {
                                        return;
                                    }
                                }
                            }
                        },

                        /**
                         * find if a string contains the string using indexOf
                         * @method inStr
                         * @param {String} src
                         * @param {String} find
                         * @return {Boolean} found
                         */
                        inStr: function inStr(src, find) {
                            return src.indexOf(find) > -1;
                        },

                        /**
                         * find if a array contains the object using indexOf or a simple polyfill
                         * @method inArray
                         * @param {String} src
                         * @param {String} find
                         * @return {Boolean|Number} false when not found, or the index
                         */
                        inArray: function inArray(src, find) {
                            if (src.indexOf) {
                                var index = src.indexOf(find);
                                return (index === -1) ? false : index;
                            } else {
                                for (var i = 0, len = src.length; i < len; i++) {
                                    if (src[i] === find) {
                                        return i;
                                    }
                                }
                                return false;
                            }
                        },

                        /**
                         * convert an array-like object (`arguments`, `touchlist`) to an array
                         * @method toArray
                         * @param {Object} obj
                         * @return {Array}
                         */
                        toArray: function toArray(obj) {
                            return Array.prototype.slice.call(obj, 0);
                        },

                        /**
                         * find if a node is in the given parent
                         * @method hasParent
                         * @param {HTMLElement} node
                         * @param {HTMLElement} parent
                         * @return {Boolean} found
                         */
                        hasParent: function hasParent(node, parent) {
                            while (node) {
                                if (node == parent) {
                                    return true;
                                }
                                node = node.parentNode;
                            }
                            return false;
                        },

                        /**
                         * get the center of all the touches
                         * @method getCenter
                         * @param {Array} touches
                         * @return {Object} center contains `pageX`, `pageY`, `clientX` and `clientY` properties
                         */
                        getCenter: function getCenter(touches) {
                            var pageX = [],
                                pageY = [],
                                clientX = [],
                                clientY = [],
                                min = Math.min,
                                max = Math.max;

                            // no need to loop when only one touch
                            if (touches.length === 1) {
                                return {
                                    pageX: touches[0].pageX,
                                    pageY: touches[0].pageY,
                                    clientX: touches[0].clientX,
                                    clientY: touches[0].clientY
                                };
                            }

                            Utils.each(touches, function(touch) {
                                pageX.push(touch.pageX);
                                pageY.push(touch.pageY);
                                clientX.push(touch.clientX);
                                clientY.push(touch.clientY);
                            });

                            return {
                                pageX: (min.apply(Math, pageX) + max.apply(Math, pageX)) / 2,
                                pageY: (min.apply(Math, pageY) + max.apply(Math, pageY)) / 2,
                                clientX: (min.apply(Math, clientX) + max.apply(Math, clientX)) / 2,
                                clientY: (min.apply(Math, clientY) + max.apply(Math, clientY)) / 2
                            };
                        },

                        /**
                         * calculate the velocity between two points. unit is in px per ms.
                         * @method getVelocity
                         * @param {Number} deltaTime
                         * @param {Number} deltaX
                         * @param {Number} deltaY
                         * @return {Object} velocity `x` and `y`
                         */
                        getVelocity: function getVelocity(deltaTime, deltaX, deltaY) {
                            return {
                                x: Math.abs(deltaX / deltaTime) || 0,
                                y: Math.abs(deltaY / deltaTime) || 0
                            };
                        },

                        /**
                         * calculate the angle between two coordinates
                         * @method getAngle
                         * @param {Touch} touch1
                         * @param {Touch} touch2
                         * @return {Number} angle
                         */
                        getAngle: function getAngle(touch1, touch2) {
                            var x = touch2.clientX - touch1.clientX,
                                y = touch2.clientY - touch1.clientY;

                            return Math.atan2(y, x) * 180 / Math.PI;
                        },

                        /**
                         * do a small comparision to get the direction between two touches.
                         * @method getDirection
                         * @param {Touch} touch1
                         * @param {Touch} touch2
                         * @return {String} direction matches `DIRECTION_LEFT|RIGHT|UP|DOWN`
                         */
                        getDirection: function getDirection(touch1, touch2) {
                            var x = Math.abs(touch1.clientX - touch2.clientX),
                                y = Math.abs(touch1.clientY - touch2.clientY);

                            if (x >= y) {
                                return touch1.clientX - touch2.clientX > 0 ? DIRECTION_LEFT : DIRECTION_RIGHT;
                            }
                            return touch1.clientY - touch2.clientY > 0 ? DIRECTION_UP : DIRECTION_DOWN;
                        },

                        /**
                         * calculate the distance between two touches
                         * @method getDistance
                         * @param {Touch}touch1
                         * @param {Touch} touch2
                         * @return {Number} distance
                         */
                        getDistance: function getDistance(touch1, touch2) {
                            var x = touch2.clientX - touch1.clientX,
                                y = touch2.clientY - touch1.clientY;

                            return Math.sqrt((x * x) + (y * y));
                        },

                        /**
                         * calculate the scale factor between two touchLists
                         * no scale is 1, and goes down to 0 when pinched together, and bigger when pinched out
                         * @method getScale
                         * @param {Array} start array of touches
                         * @param {Array} end array of touches
                         * @return {Number} scale
                         */
                        getScale: function getScale(start, end) {
                            // need two fingers...
                            if (start.length >= 2 && end.length >= 2) {
                                return this.getDistance(end[0], end[1]) / this.getDistance(start[0], start[1]);
                            }
                            return 1;
                        },

                        /**
                         * calculate the rotation degrees between two touchLists
                         * @method getRotation
                         * @param {Array} start array of touches
                         * @param {Array} end array of touches
                         * @return {Number} rotation
                         */
                        getRotation: function getRotation(start, end) {
                            // need two fingers
                            if (start.length >= 2 && end.length >= 2) {
                                return this.getAngle(end[1], end[0]) - this.getAngle(start[1], start[0]);
                            }
                            return 0;
                        },

                        /**
                         * find out if the direction is vertical   *
                         * @method isVertical
                         * @param {String} direction matches `DIRECTION_UP|DOWN`
                         * @return {Boolean} is_vertical
                         */
                        isVertical: function isVertical(direction) {
                            return direction == DIRECTION_UP || direction == DIRECTION_DOWN;
                        },

                        /**
                         * set css properties with their prefixes
                         * @param {HTMLElement} element
                         * @param {String} prop
                         * @param {String} value
                         * @param {Boolean} [toggle=true]
                         * @return {Boolean}
                         */
                        setPrefixedCss: function setPrefixedCss(element, prop, value, toggle) {
                            var prefixes = ['', 'Webkit', 'Moz', 'O', 'ms'];
                            prop = Utils.toCamelCase(prop);

                            for (var i = 0; i < prefixes.length; i++) {
                                var p = prop;
                                // prefixes
                                if (prefixes[i]) {
                                    p = prefixes[i] + p.slice(0, 1).toUpperCase() + p.slice(1);
                                }

                                // test the style
                                if (p in element.style) {
                                    element.style[p] = (toggle == null || toggle) && value || '';
                                    break;
                                }
                            }
                        },

                        /**
                         * toggle browser default behavior by setting css properties.
                         * `userSelect='none'` also sets `element.onselectstart` to false
                         * `userDrag='none'` also sets `element.ondragstart` to false
                         *
                         * @method toggleBehavior
                         * @param {HtmlElement} element
                         * @param {Object} props
                         * @param {Boolean} [toggle=true]
                         */
                        toggleBehavior: function toggleBehavior(element, props, toggle) {
                            if (!props || !element || !element.style) {
                                return;
                            }

                            // set the css properties
                            Utils.each(props, function(value, prop) {
                                Utils.setPrefixedCss(element, prop, value, toggle);
                            });

                            var falseFn = toggle && function() {
                                return false;
                            };

                            // also the disable onselectstart
                            if (props.userSelect == 'none') {
                                element.onselectstart = falseFn;
                            }
                            // and disable ondragstart
                            if (props.userDrag == 'none') {
                                element.ondragstart = falseFn;
                            }
                        },

                        /**
                         * convert a string with underscores to camelCase
                         * so prevent_default becomes preventDefault
                         * @param {String} str
                         * @return {String} camelCaseStr
                         */
                        toCamelCase: function toCamelCase(str) {
                            return str.replace(/[_-]([a-z])/g, function(s) {
                                return s[1].toUpperCase();
                            });
                        }
                    };


                    /**
                     * @module hammer
                     */
                    /**
                     * @class Event
                     * @static
                     */
                    var Event = Hammer.event = {
                        /**
                         * when touch events have been fired, this is true
                         * this is used to stop mouse events
                         * @property prevent_mouseevents
                         * @private
                         * @type {Boolean}
                         */
                        preventMouseEvents: false,

                        /**
                         * if EVENT_START has been fired
                         * @property started
                         * @private
                         * @type {Boolean}
                         */
                        started: false,

                        /**
                         * when the mouse is hold down, this is true
                         * @property should_detect
                         * @private
                         * @type {Boolean}
                         */
                        shouldDetect: false,

                        /**
                         * simple event binder with a hook and support for multiple types
                         * @method on
                         * @param {HTMLElement} element
                         * @param {String} type
                         * @param {Function} handler
                         * @param {Function} [hook]
                         * @param {Object} hook.type
                         */
                        on: function on(element, type, handler, hook) {
                            var types = type.split(' ');
                            Utils.each(types, function(type) {
                                Utils.on(element, type, handler);
                                hook && hook(type);
                            });
                        },

                        /**
                         * simple event unbinder with a hook and support for multiple types
                         * @method off
                         * @param {HTMLElement} element
                         * @param {String} type
                         * @param {Function} handler
                         * @param {Function} [hook]
                         * @param {Object} hook.type
                         */
                        off: function off(element, type, handler, hook) {
                            var types = type.split(' ');
                            Utils.each(types, function(type) {
                                Utils.off(element, type, handler);
                                hook && hook(type);
                            });
                        },

                        /**
                         * the core touch event handler.
                         * this finds out if we should to detect gestures
                         * @method onTouch
                         * @param {HTMLElement} element
                         * @param {String} eventType matches `EVENT_START|MOVE|END`
                         * @param {Function} handler
                         * @return onTouchHandler {Function} the core event handler
                         */
                        onTouch: function onTouch(element, eventType, handler) {
                            var self = this;

                            var onTouchHandler = function onTouchHandler(ev) {
                                var srcType = ev.type.toLowerCase(),
                                    isPointer = Hammer.HAS_POINTEREVENTS,
                                    isMouse = Utils.inStr(srcType, 'mouse'),
                                    triggerType;

                                // if we are in a mouseevent, but there has been a touchevent triggered in this session
                                // we want to do nothing. simply break out of the event.
                                if (isMouse && self.preventMouseEvents) {
                                    return;

                                    // mousebutton must be down
                                } else if (isMouse && eventType == EVENT_START && ev.button === 0) {
                                    self.preventMouseEvents = false;
                                    self.shouldDetect = true;
                                } else if (isPointer && eventType == EVENT_START) {
                                    self.shouldDetect = (ev.buttons === 1 || PointerEvent.matchType(POINTER_TOUCH, ev));
                                    // just a valid start event, but no mouse
                                } else if (!isMouse && eventType == EVENT_START) {
                                    self.preventMouseEvents = true;
                                    self.shouldDetect = true;
                                }

                                // update the pointer event before entering the detection
                                if (isPointer && eventType != EVENT_END) {
                                    PointerEvent.updatePointer(eventType, ev);
                                }

                                // we are in a touch/down state, so allowed detection of gestures
                                if (self.shouldDetect) {
                                    triggerType = self.doDetect.call(self, ev, eventType, element, handler);
                                }

                                // ...and we are done with the detection
                                // so reset everything to start each detection totally fresh
                                if (triggerType == EVENT_END) {
                                    self.preventMouseEvents = false;
                                    self.shouldDetect = false;
                                    PointerEvent.reset();
                                    // update the pointerevent object after the detection
                                }

                                if (isPointer && eventType == EVENT_END) {
                                    PointerEvent.updatePointer(eventType, ev);
                                }
                            };

                            this.on(element, EVENT_TYPES[eventType], onTouchHandler);
                            return onTouchHandler;
                        },

                        /**
                         * the core detection method
                         * this finds out what hammer-touch-events to trigger
                         * @method doDetect
                         * @param {Object} ev
                         * @param {String} eventType matches `EVENT_START|MOVE|END`
                         * @param {HTMLElement} element
                         * @param {Function} handler
                         * @return {String} triggerType matches `EVENT_START|MOVE|END`
                         */
                        doDetect: function doDetect(ev, eventType, element, handler) {
                            var touchList = this.getTouchList(ev, eventType);
                            var touchListLength = touchList.length;
                            var triggerType = eventType;
                            var triggerChange = touchList.trigger; // used by fakeMultitouch plugin
                            var changedLength = touchListLength;

                            // at each touchstart-like event we want also want to trigger a TOUCH event...
                            if (eventType == EVENT_START) {
                                triggerChange = EVENT_TOUCH;
                                // ...the same for a touchend-like event
                            } else if (eventType == EVENT_END) {
                                triggerChange = EVENT_RELEASE;

                                // keep track of how many touches have been removed
                                changedLength = touchList.length - ((ev.changedTouches) ? ev.changedTouches.length : 1);
                            }

                            // after there are still touches on the screen,
                            // we just want to trigger a MOVE event. so change the START or END to a MOVE
                            // but only after detection has been started, the first time we actualy want a START
                            if (changedLength > 0 && this.started) {
                                triggerType = EVENT_MOVE;
                            }

                            // detection has been started, we keep track of this, see above
                            this.started = true;

                            // generate some event data, some basic information
                            var evData = this.collectEventData(element, triggerType, touchList, ev);

                            // trigger the triggerType event before the change (TOUCH, RELEASE) events
                            // but the END event should be at last
                            if (eventType != EVENT_END) {
                                handler.call(Detection, evData);
                            }

                            // trigger a change (TOUCH, RELEASE) event, this means the length of the touches changed
                            if (triggerChange) {
                                evData.changedLength = changedLength;
                                evData.eventType = triggerChange;

                                handler.call(Detection, evData);

                                evData.eventType = triggerType;
                                delete evData.changedLength;
                            }

                            // trigger the END event
                            if (triggerType == EVENT_END) {
                                handler.call(Detection, evData);

                                // ...and we are done with the detection
                                // so reset everything to start each detection totally fresh
                                this.started = false;
                            }

                            return triggerType;
                        },

                        /**
                         * we have different events for each device/browser
                         * determine what we need and set them in the EVENT_TYPES constant
                         * the `onTouch` method is bind to these properties.
                         * @method determineEventTypes
                         * @return {Object} events
                         */
                        determineEventTypes: function determineEventTypes() {
                            var types;
                            if (Hammer.HAS_POINTEREVENTS) {
                                if (window.PointerEvent) {
                                    types = [
                                        'pointerdown',
                                        'pointermove',
                                        'pointerup pointercancel lostpointercapture'
                                    ];
                                } else {
                                    types = [
                                        'MSPointerDown',
                                        'MSPointerMove',
                                        'MSPointerUp MSPointerCancel MSLostPointerCapture'
                                    ];
                                }
                            } else if (Hammer.NO_MOUSEEVENTS) {
                                types = [
                                    'touchstart',
                                    'touchmove',
                                    'touchend touchcancel'
                                ];
                            } else {
                                types = [
                                    'touchstart mousedown',
                                    'touchmove mousemove',
                                    'touchend touchcancel mouseup'
                                ];
                            }

                            EVENT_TYPES[EVENT_START] = types[0];
                            EVENT_TYPES[EVENT_MOVE] = types[1];
                            EVENT_TYPES[EVENT_END] = types[2];
                            return EVENT_TYPES;
                        },

                        /**
                         * create touchList depending on the event
                         * @method getTouchList
                         * @param {Object} ev
                         * @param {String} eventType
                         * @return {Array} touches
                         */
                        getTouchList: function getTouchList(ev, eventType) {
                            // get the fake pointerEvent touchlist
                            if (Hammer.HAS_POINTEREVENTS) {
                                return PointerEvent.getTouchList();
                            }

                            // get the touchlist
                            if (ev.touches) {
                                if (eventType == EVENT_MOVE) {
                                    return ev.touches;
                                }

                                var identifiers = [];
                                var concat = [].concat(Utils.toArray(ev.touches), Utils.toArray(ev.changedTouches));
                                var touchList = [];

                                Utils.each(concat, function(touch) {
                                    if (Utils.inArray(identifiers, touch.identifier) === false) {
                                        touchList.push(touch);
                                    }
                                    identifiers.push(touch.identifier);
                                });

                                return touchList;
                            }

                            // make fake touchList from mouse position
                            ev.identifier = 1;
                            return [ev];
                        },

                        /**
                         * collect basic event data
                         * @method collectEventData
                         * @param {HTMLElement} element
                         * @param {String} eventType matches `EVENT_START|MOVE|END`
                         * @param {Array} touches
                         * @param {Object} ev
                         * @return {Object} ev
                         */
                        collectEventData: function collectEventData(element, eventType, touches, ev) {
                            // find out pointerType
                            var pointerType = POINTER_TOUCH;
                            if (Utils.inStr(ev.type, 'mouse') || PointerEvent.matchType(POINTER_MOUSE, ev)) {
                                pointerType = POINTER_MOUSE;
                            } else if (PointerEvent.matchType(POINTER_PEN, ev)) {
                                pointerType = POINTER_PEN;
                            }

                            return {
                                center: Utils.getCenter(touches),
                                timeStamp: Date.now(),
                                target: ev.target,
                                touches: touches,
                                eventType: eventType,
                                pointerType: pointerType,
                                srcEvent: ev,

                                /**
                                 * prevent the browser default actions
                                 * mostly used to disable scrolling of the browser
                                 */
                                preventDefault: function() {
                                    var srcEvent = this.srcEvent;
                                    srcEvent.preventManipulation && srcEvent.preventManipulation();
                                    srcEvent.preventDefault && srcEvent.preventDefault();
                                },

                                /**
                                 * stop bubbling the event up to its parents
                                 */
                                stopPropagation: function() {
                                    this.srcEvent.stopPropagation();
                                },

                                /**
                                 * immediately stop gesture detection
                                 * might be useful after a swipe was detected
                                 * @return {*}
                                 */
                                stopDetect: function() {
                                    return Detection.stopDetect();
                                }
                            };
                        }
                    };


                    /**
                     * @module hammer
                     *
                     * @class PointerEvent
                     * @static
                     */
                    var PointerEvent = Hammer.PointerEvent = {
                        /**
                         * holds all pointers, by `identifier`
                         * @property pointers
                         * @type {Object}
                         */
                        pointers: {},

                        /**
                         * get the pointers as an array
                         * @method getTouchList
                         * @return {Array} touchlist
                         */
                        getTouchList: function getTouchList() {
                            var touchlist = [];
                            // we can use forEach since pointerEvents only is in IE10
                            Utils.each(this.pointers, function(pointer) {
                                touchlist.push(pointer);
                            });
                            return touchlist;
                        },

                        /**
                         * update the position of a pointer
                         * @method updatePointer
                         * @param {String} eventType matches `EVENT_START|MOVE|END`
                         * @param {Object} pointerEvent
                         */
                        updatePointer: function updatePointer(eventType, pointerEvent) {
                            if (eventType == EVENT_END || (eventType != EVENT_END && pointerEvent.buttons !== 1)) {
                                delete this.pointers[pointerEvent.pointerId];
                            } else {
                                pointerEvent.identifier = pointerEvent.pointerId;
                                this.pointers[pointerEvent.pointerId] = pointerEvent;
                            }
                        },

                        /**
                         * check if ev matches pointertype
                         * @method matchType
                         * @param {String} pointerType matches `POINTER_MOUSE|TOUCH|PEN`
                         * @param {PointerEvent} ev
                         */
                        matchType: function matchType(pointerType, ev) {
                            if (!ev.pointerType) {
                                return false;
                            }

                            var pt = ev.pointerType,
                                types = {};

                            types[POINTER_MOUSE] = (pt === (ev.MSPOINTER_TYPE_MOUSE || POINTER_MOUSE));
                            types[POINTER_TOUCH] = (pt === (ev.MSPOINTER_TYPE_TOUCH || POINTER_TOUCH));
                            types[POINTER_PEN] = (pt === (ev.MSPOINTER_TYPE_PEN || POINTER_PEN));
                            return types[pointerType];
                        },

                        /**
                         * reset the stored pointers
                         * @method reset
                         */
                        reset: function resetList() {
                            this.pointers = {};
                        }
                    };


                    /**
                     * @module hammer
                     *
                     * @class Detection
                     * @static
                     */
                    var Detection = Hammer.detection = {
                        // contains all registred Hammer.gestures in the correct order
                        gestures: [],

                        // data of the current Hammer.gesture detection session
                        current: null,

                        // the previous Hammer.gesture session data
                        // is a full clone of the previous gesture.current object
                        previous: null,

                        // when this becomes true, no gestures are fired
                        stopped: false,

                        /**
                         * start Hammer.gesture detection
                         * @method startDetect
                         * @param {Hammer.Instance} inst
                         * @param {Object} eventData
                         */
                        startDetect: function startDetect(inst, eventData) {
                            // already busy with a Hammer.gesture detection on an element
                            if (this.current) {
                                return;
                            }

                            this.stopped = false;

                            // holds current session
                            this.current = {
                                inst: inst, // reference to HammerInstance we're working for
                                startEvent: Utils.extend({}, eventData), // start eventData for distances, timing etc
                                lastEvent: false, // last eventData
                                lastCalcEvent: false, // last eventData for calculations.
                                futureCalcEvent: false, // last eventData for calculations.
                                lastCalcData: {}, // last lastCalcData
                                name: '' // current gesture we're in/detected, can be 'tap', 'hold' etc
                            };

                            this.detect(eventData);
                        },

                        /**
                         * Hammer.gesture detection
                         * @method detect
                         * @param {Object} eventData
                         * @return {any}
                         */
                        detect: function detect(eventData) {
                            if (!this.current || this.stopped) {
                                return;
                            }

                            // extend event data with calculations about scale, distance etc
                            eventData = this.extendEventData(eventData);

                            // hammer instance and instance options
                            var inst = this.current.inst,
                                instOptions = inst.options;

                            // call Hammer.gesture handlers
                            Utils.each(this.gestures, function triggerGesture(gesture) {
                                // only when the instance options have enabled this gesture
                                if (!this.stopped && inst.enabled && instOptions[gesture.name]) {
                                    gesture.handler.call(gesture, eventData, inst);
                                }
                            }, this);

                            // store as previous event event
                            if (this.current) {
                                this.current.lastEvent = eventData;
                            }

                            if (eventData.eventType == EVENT_END) {
                                this.stopDetect();
                            }

                            return eventData;
                        },

                        /**
                         * clear the Hammer.gesture vars
                         * this is called on endDetect, but can also be used when a final Hammer.gesture has been detected
                         * to stop other Hammer.gestures from being fired
                         * @method stopDetect
                         */
                        stopDetect: function stopDetect() {
                            // clone current data to the store as the previous gesture
                            // used for the double tap gesture, since this is an other gesture detect session
                            this.previous = Utils.extend({}, this.current);

                            // reset the current
                            this.current = null;
                            this.stopped = true;
                        },

                        /**
                         * calculate velocity, angle and direction
                         * @method getVelocityData
                         * @param {Object} ev
                         * @param {Object} center
                         * @param {Number} deltaTime
                         * @param {Number} deltaX
                         * @param {Number} deltaY
                         */
                        getCalculatedData: function getCalculatedData(ev, center, deltaTime, deltaX, deltaY) {
                            var cur = this.current,
                                recalc = false,
                                calcEv = cur.lastCalcEvent,
                                calcData = cur.lastCalcData;

                            if (calcEv && ev.timeStamp - calcEv.timeStamp > Hammer.CALCULATE_INTERVAL) {
                                center = calcEv.center;
                                deltaTime = ev.timeStamp - calcEv.timeStamp;
                                deltaX = ev.center.clientX - calcEv.center.clientX;
                                deltaY = ev.center.clientY - calcEv.center.clientY;
                                recalc = true;
                            }

                            if (ev.eventType == EVENT_TOUCH || ev.eventType == EVENT_RELEASE) {
                                cur.futureCalcEvent = ev;
                            }

                            if (!cur.lastCalcEvent || recalc) {
                                calcData.velocity = Utils.getVelocity(deltaTime, deltaX, deltaY);
                                calcData.angle = Utils.getAngle(center, ev.center);
                                calcData.direction = Utils.getDirection(center, ev.center);

                                cur.lastCalcEvent = cur.futureCalcEvent || ev;
                                cur.futureCalcEvent = ev;
                            }

                            ev.velocityX = calcData.velocity.x;
                            ev.velocityY = calcData.velocity.y;
                            ev.interimAngle = calcData.angle;
                            ev.interimDirection = calcData.direction;
                        },

                        /**
                         * extend eventData for Hammer.gestures
                         * @method extendEventData
                         * @param {Object} ev
                         * @return {Object} ev
                         */
                        extendEventData: function extendEventData(ev) {
                            var cur = this.current,
                                startEv = cur.startEvent,
                                lastEv = cur.lastEvent || startEv;

                            // update the start touchlist to calculate the scale/rotation
                            if (ev.eventType == EVENT_TOUCH || ev.eventType == EVENT_RELEASE) {
                                startEv.touches = [];
                                Utils.each(ev.touches, function(touch) {
                                    startEv.touches.push({
                                        clientX: touch.clientX,
                                        clientY: touch.clientY
                                    });
                                });
                            }

                            var deltaTime = ev.timeStamp - startEv.timeStamp,
                                deltaX = ev.center.clientX - startEv.center.clientX,
                                deltaY = ev.center.clientY - startEv.center.clientY;

                            this.getCalculatedData(ev, lastEv.center, deltaTime, deltaX, deltaY);

                            Utils.extend(ev, {
                                startEvent: startEv,

                                deltaTime: deltaTime,
                                deltaX: deltaX,
                                deltaY: deltaY,

                                distance: Utils.getDistance(startEv.center, ev.center),
                                angle: Utils.getAngle(startEv.center, ev.center),
                                direction: Utils.getDirection(startEv.center, ev.center),
                                scale: Utils.getScale(startEv.touches, ev.touches),
                                rotation: Utils.getRotation(startEv.touches, ev.touches)
                            });

                            return ev;
                        },

                        /**
                         * register new gesture
                         * @method register
                         * @param {Object} gesture object, see `gestures/` for documentation
                         * @return {Array} gestures
                         */
                        register: function register(gesture) {
                            // add an enable gesture options if there is no given
                            var options = gesture.defaults || {};
                            if (options[gesture.name] === undefined) {
                                options[gesture.name] = true;
                            }

                            // extend Hammer default options with the Hammer.gesture options
                            Utils.extend(Hammer.defaults, options, true);

                            // set its index
                            gesture.index = gesture.index || 1000;

                            // add Hammer.gesture to the list
                            this.gestures.push(gesture);

                            // sort the list by index
                            this.gestures.sort(function(a, b) {
                                if (a.index < b.index) {
                                    return -1;
                                }
                                if (a.index > b.index) {
                                    return 1;
                                }
                                return 0;
                            });

                            return this.gestures;
                        }
                    };


                    /**
                     * @module hammer
                     */

                    /**
                     * create new hammer instance
                     * all methods should return the instance itself, so it is chainable.
                     *
                     * @class Instance
                     * @constructor
                     * @param {HTMLElement} element
                     * @param {Object} [options={}] options are merged with `Hammer.defaults`
                     * @return {Hammer.Instance}
                     */
                    Hammer.Instance = function(element, options) {
                        var self = this;

                        // setup HammerJS window events and register all gestures
                        // this also sets up the default options
                        setup();

                        /**
                         * @property element
                         * @type {HTMLElement}
                         */
                        this.element = element;

                        /**
                         * @property enabled
                         * @type {Boolean}
                         * @protected
                         */
                        this.enabled = true;

                        /**
                         * options, merged with the defaults
                         * options with an _ are converted to camelCase
                         * @property options
                         * @type {Object}
                         */
                        Utils.each(options, function(value, name) {
                            delete options[name];
                            options[Utils.toCamelCase(name)] = value;
                        });

                        this.options = Utils.extend(Utils.extend({}, Hammer.defaults), options || {});

                        // add some css to the element to prevent the browser from doing its native behavoir
                        if (this.options.behavior) {
                            Utils.toggleBehavior(this.element, this.options.behavior, true);
                        }

                        /**
                         * event start handler on the element to start the detection
                         * @property eventStartHandler
                         * @type {Object}
                         */
                        this.eventStartHandler = Event.onTouch(element, EVENT_START, function(ev) {
                            if (self.enabled && ev.eventType == EVENT_START) {
                                Detection.startDetect(self, ev);
                            } else if (ev.eventType == EVENT_TOUCH) {
                                Detection.detect(ev);
                            }
                        });

                        /**
                         * keep a list of user event handlers which needs to be removed when calling 'dispose'
                         * @property eventHandlers
                         * @type {Array}
                         */
                        this.eventHandlers = [];
                    };

                    Hammer.Instance.prototype = {
                        /**
                         * bind events to the instance
                         * @method on
                         * @chainable
                         * @param {String} gestures multiple gestures by splitting with a space
                         * @param {Function} handler
                         * @param {Object} handler.ev event object
                         */
                        on: function onEvent(gestures, handler) {
                            var self = this;
                            Event.on(self.element, gestures, handler, function(type) {
                                self.eventHandlers.push({
                                    gesture: type,
                                    handler: handler
                                });
                            });
                            return self;
                        },

                        /**
                         * unbind events to the instance
                         * @method off
                         * @chainable
                         * @param {String} gestures
                         * @param {Function} handler
                         */
                        off: function offEvent(gestures, handler) {
                            var self = this;

                            Event.off(self.element, gestures, handler, function(type) {
                                var index = Utils.inArray({
                                    gesture: type,
                                    handler: handler
                                });
                                if (index !== false) {
                                    self.eventHandlers.splice(index, 1);
                                }
                            });
                            return self;
                        },

                        /**
                         * trigger gesture event
                         * @method trigger
                         * @chainable
                         * @param {String} gesture
                         * @param {Object} [eventData]
                         */
                        trigger: function triggerEvent(gesture, eventData) {
                            // optional
                            if (!eventData) {
                                eventData = {};
                            }

                            // create DOM event
                            var event = Hammer.DOCUMENT.createEvent('Event');
                            event.initEvent(gesture, true, true);
                            event.gesture = eventData;

                            // trigger on the target if it is in the instance element,
                            // this is for event delegation tricks
                            var element = this.element;
                            if (Utils.hasParent(eventData.target, element)) {
                                element = eventData.target;
                            }

                            element.dispatchEvent(event);
                            return this;
                        },

                        /**
                         * enable of disable hammer.js detection
                         * @method enable
                         * @chainable
                         * @param {Boolean} state
                         */
                        enable: function enable(state) {
                            this.enabled = state;
                            return this;
                        },

                        /**
                         * dispose this hammer instance
                         * @method dispose
                         * @return {Null}
                         */
                        dispose: function dispose() {
                            var i, eh;

                            // undo all changes made by stop_browser_behavior
                            Utils.toggleBehavior(this.element, this.options.behavior, false);

                            // unbind all custom event handlers
                            for (i = -1;
                                (eh = this.eventHandlers[++i]);) {
                                Utils.off(this.element, eh.gesture, eh.handler);
                            }

                            this.eventHandlers = [];

                            // unbind the start event listener
                            Event.off(this.element, EVENT_TYPES[EVENT_START], this.eventStartHandler);

                            return null;
                        }
                    };


                    /**
                     * @module gestures
                     */
                    /**
                     * Move with x fingers (default 1) around on the page.
                     * Preventing the default browser behavior is a good way to improve feel and working.
                     * ````
                     *  hammertime.on("drag", function(ev) {
                     *    console.log(ev);
                     *    ev.gesture.preventDefault();
                     *  });
                     * ````
                     *
                     * @class Drag
                     * @static
                     */
                    /**
                     * @event drag
                     * @param {Object} ev
                     */
                    /**
                     * @event dragstart
                     * @param {Object} ev
                     */
                    /**
                     * @event dragend
                     * @param {Object} ev
                     */
                    /**
                     * @event drapleft
                     * @param {Object} ev
                     */
                    /**
                     * @event dragright
                     * @param {Object} ev
                     */
                    /**
                     * @event dragup
                     * @param {Object} ev
                     */
                    /**
                     * @event dragdown
                     * @param {Object} ev
                     */

                    /**
                     * @param {String} name
                     */
                    (function(name) {
                        var triggered = false;

                        function dragGesture(ev, inst) {
                            var cur = Detection.current;

                            // max touches
                            if (inst.options.dragMaxTouches > 0 &&
                                ev.touches.length > inst.options.dragMaxTouches) {
                                return;
                            }

                            switch (ev.eventType) {
                                case EVENT_START:
                                    triggered = false;
                                    break;

                                case EVENT_MOVE:
                                    // when the distance we moved is too small we skip this gesture
                                    // or we can be already in dragging
                                    if (ev.distance < inst.options.dragMinDistance &&
                                        cur.name != name) {
                                        return;
                                    }

                                    var startCenter = cur.startEvent.center;

                                    // we are dragging!
                                    if (cur.name != name) {
                                        cur.name = name;
                                        if (inst.options.dragDistanceCorrection && ev.distance > 0) {
                                            // When a drag is triggered, set the event center to dragMinDistance pixels from the original event center.
                                            // Without this correction, the dragged distance would jumpstart at dragMinDistance pixels instead of at 0.
                                            // It might be useful to save the original start point somewhere
                                            var factor = Math.abs(inst.options.dragMinDistance / ev.distance);
                                            startCenter.pageX += ev.deltaX * factor;
                                            startCenter.pageY += ev.deltaY * factor;
                                            startCenter.clientX += ev.deltaX * factor;
                                            startCenter.clientY += ev.deltaY * factor;

                                            // recalculate event data using new start point
                                            ev = Detection.extendEventData(ev);
                                        }
                                    }

                                    // lock drag to axis?
                                    if (cur.lastEvent.dragLockToAxis ||
                                        (inst.options.dragLockToAxis &&
                                            inst.options.dragLockMinDistance <= ev.distance
                                        )) {
                                        ev.dragLockToAxis = true;
                                    }

                                    // keep direction on the axis that the drag gesture started on
                                    var lastDirection = cur.lastEvent.direction;
                                    if (ev.dragLockToAxis && lastDirection !== ev.direction) {
                                        if (Utils.isVertical(lastDirection)) {
                                            ev.direction = (ev.deltaY < 0) ? DIRECTION_UP : DIRECTION_DOWN;
                                        } else {
                                            ev.direction = (ev.deltaX < 0) ? DIRECTION_LEFT : DIRECTION_RIGHT;
                                        }
                                    }

                                    // first time, trigger dragstart event
                                    if (!triggered) {
                                        inst.trigger(name + 'start', ev);
                                        triggered = true;
                                    }

                                    // trigger events
                                    inst.trigger(name, ev);
                                    inst.trigger(name + ev.direction, ev);

                                    var isVertical = Utils.isVertical(ev.direction);

                                    // block the browser events
                                    if ((inst.options.dragBlockVertical && isVertical) ||
                                        (inst.options.dragBlockHorizontal && !isVertical)) {
                                        ev.preventDefault();
                                    }
                                    break;

                                case EVENT_RELEASE:
                                    if (triggered && ev.changedLength <= inst.options.dragMaxTouches) {
                                        inst.trigger(name + 'end', ev);
                                        triggered = false;
                                    }
                                    break;

                                case EVENT_END:
                                    triggered = false;
                                    break;
                            }
                        }

                        Hammer.gestures.Drag = {
                            name: name,
                            index: 50,
                            handler: dragGesture,
                            defaults: {
                                /**
                                 * minimal movement that have to be made before the drag event gets triggered
                                 * @property dragMinDistance
                                 * @type {Number}
                                 * @default 10
                                 */
                                dragMinDistance: 10,

                                /**
                                 * Set dragDistanceCorrection to true to make the starting point of the drag
                                 * be calculated from where the drag was triggered, not from where the touch started.
                                 * Useful to avoid a jerk-starting drag, which can make fine-adjustments
                                 * through dragging difficult, and be visually unappealing.
                                 * @property dragDistanceCorrection
                                 * @type {Boolean}
                                 * @default true
                                 */
                                dragDistanceCorrection: true,

                                /**
                                 * set 0 for unlimited, but this can conflict with transform
                                 * @property dragMaxTouches
                                 * @type {Number}
                                 * @default 1
                                 */
                                dragMaxTouches: 1,

                                /**
                                 * prevent default browser behavior when dragging occurs
                                 * be careful with it, it makes the element a blocking element
                                 * when you are using the drag gesture, it is a good practice to set this true
                                 * @property dragBlockHorizontal
                                 * @type {Boolean}
                                 * @default false
                                 */
                                dragBlockHorizontal: false,

                                /**
                                 * same as `dragBlockHorizontal`, but for vertical movement
                                 * @property dragBlockVertical
                                 * @type {Boolean}
                                 * @default false
                                 */
                                dragBlockVertical: false,

                                /**
                                 * dragLockToAxis keeps the drag gesture on the axis that it started on,
                                 * It disallows vertical directions if the initial direction was horizontal, and vice versa.
                                 * @property dragLockToAxis
                                 * @type {Boolean}
                                 * @default false
                                 */
                                dragLockToAxis: false,

                                /**
                                 * drag lock only kicks in when distance > dragLockMinDistance
                                 * This way, locking occurs only when the distance has become large enough to reliably determine the direction
                                 * @property dragLockMinDistance
                                 * @type {Number}
                                 * @default 25
                                 */
                                dragLockMinDistance: 25
                            }
                        };
                    })('drag');

                    /**
                     * @module gestures
                     */
                    /**
                     * trigger a simple gesture event, so you can do anything in your handler.
                     * only usable if you know what your doing...
                     *
                     * @class Gesture
                     * @static
                     */
                    /**
                     * @event gesture
                     * @param {Object} ev
                     */
                    Hammer.gestures.Gesture = {
                        name: 'gesture',
                        index: 1337,
                        handler: function releaseGesture(ev, inst) {
                            inst.trigger(this.name, ev);
                        }
                    };

                    /**
                     * @module gestures
                     */
                    /**
                     * Touch stays at the same place for x time
                     *
                     * @class Hold
                     * @static
                     */
                    /**
                     * @event hold
                     * @param {Object} ev
                     */

                    /**
                     * @param {String} name
                     */
                    (function(name) {
                        var timer;

                        function holdGesture(ev, inst) {
                            var options = inst.options,
                                current = Detection.current;

                            switch (ev.eventType) {
                                case EVENT_START:
                                    clearTimeout(timer);

                                    // set the gesture so we can check in the timeout if it still is
                                    current.name = name;

                                    // set timer and if after the timeout it still is hold,
                                    // we trigger the hold event
                                    timer = setTimeout(function() {
                                        if (current && current.name == name) {
                                            inst.trigger(name, ev);
                                        }
                                    }, options.holdTimeout);
                                    break;

                                case EVENT_MOVE:
                                    if (ev.distance > options.holdThreshold) {
                                        clearTimeout(timer);
                                    }
                                    break;

                                case EVENT_RELEASE:
                                    clearTimeout(timer);
                                    break;
                            }
                        }

                        Hammer.gestures.Hold = {
                            name: name,
                            index: 10,
                            defaults: {
                                /**
                                 * @property holdTimeout
                                 * @type {Number}
                                 * @default 500
                                 */
                                holdTimeout: 500,

                                /**
                                 * movement allowed while holding
                                 * @property holdThreshold
                                 * @type {Number}
                                 * @default 2
                                 */
                                holdThreshold: 2
                            },
                            handler: holdGesture
                        };
                    })('hold');

                    /**
                     * @module gestures
                     */
                    /**
                     * when a touch is being released from the page
                     *
                     * @class Release
                     * @static
                     */
                    /**
                     * @event release
                     * @param {Object} ev
                     */
                    Hammer.gestures.Release = {
                        name: 'release',
                        index: Infinity,
                        handler: function releaseGesture(ev, inst) {
                            if (ev.eventType == EVENT_RELEASE) {
                                inst.trigger(this.name, ev);
                            }
                        }
                    };

                    /**
                     * @module gestures
                     */
                    /**
                     * triggers swipe events when the end velocity is above the threshold
                     * for best usage, set `preventDefault` (on the drag gesture) to `true`
                     * ````
                     *  hammertime.on("dragleft swipeleft", function(ev) {
                     *    console.log(ev);
                     *    ev.gesture.preventDefault();
                     *  });
                     * ````
                     *
                     * @class Swipe
                     * @static
                     */
                    /**
                     * @event swipe
                     * @param {Object} ev
                     */
                    /**
                     * @event swipeleft
                     * @param {Object} ev
                     */
                    /**
                     * @event swiperight
                     * @param {Object} ev
                     */
                    /**
                     * @event swipeup
                     * @param {Object} ev
                     */
                    /**
                     * @event swipedown
                     * @param {Object} ev
                     */
                    Hammer.gestures.Swipe = {
                        name: 'swipe',
                        index: 40,
                        defaults: {
                            /**
                             * @property swipeMinTouches
                             * @type {Number}
                             * @default 1
                             */
                            swipeMinTouches: 1,

                            /**
                             * @property swipeMaxTouches
                             * @type {Number}
                             * @default 1
                             */
                            swipeMaxTouches: 1,

                            /**
                             * horizontal swipe velocity
                             * @property swipeVelocityX
                             * @type {Number}
                             * @default 0.6
                             */
                            swipeVelocityX: 0.6,

                            /**
                             * vertical swipe velocity
                             * @property swipeVelocityY
                             * @type {Number}
                             * @default 0.6
                             */
                            swipeVelocityY: 0.6
                        },

                        handler: function swipeGesture(ev, inst) {
                            if (ev.eventType == EVENT_RELEASE) {
                                var touches = ev.touches.length,
                                    options = inst.options;

                                // max touches
                                if (touches < options.swipeMinTouches ||
                                    touches > options.swipeMaxTouches) {
                                    return;
                                }

                                // when the distance we moved is too small we skip this gesture
                                // or we can be already in dragging
                                if (ev.velocityX > options.swipeVelocityX ||
                                    ev.velocityY > options.swipeVelocityY) {
                                    // trigger swipe events
                                    inst.trigger(this.name, ev);
                                    inst.trigger(this.name + ev.direction, ev);
                                }
                            }
                        }
                    };

                    /**
                     * @module gestures
                     */
                    /**
                     * Single tap and a double tap on a place
                     *
                     * @class Tap
                     * @static
                     */
                    /**
                     * @event tap
                     * @param {Object} ev
                     */
                    /**
                     * @event doubletap
                     * @param {Object} ev
                     */

                    /**
                     * @param {String} name
                     */
                    (function(name) {
                        var hasMoved = false;

                        function tapGesture(ev, inst) {
                            var options = inst.options,
                                current = Detection.current,
                                prev = Detection.previous,
                                sincePrev,
                                didDoubleTap;

                            switch (ev.eventType) {
                                case EVENT_START:
                                    hasMoved = false;
                                    break;

                                case EVENT_MOVE:
                                    hasMoved = hasMoved || (ev.distance > options.tapMaxDistance);
                                    break;

                                case EVENT_END:
                                    if (!Utils.inStr(ev.srcEvent.type, 'cancel') && ev.deltaTime < options.tapMaxTime && !hasMoved) {
                                        // previous gesture, for the double tap since these are two different gesture detections
                                        sincePrev = prev && prev.lastEvent && ev.timeStamp - prev.lastEvent.timeStamp;
                                        didDoubleTap = false;

                                        // check if double tap
                                        if (prev && prev.name == name &&
                                            (sincePrev && sincePrev < options.doubleTapInterval) &&
                                            ev.distance < options.doubleTapDistance) {
                                            inst.trigger('doubletap', ev);
                                            didDoubleTap = true;
                                        }

                                        // do a single tap
                                        if (!didDoubleTap || options.tapAlways) {
                                            current.name = name;
                                            inst.trigger(current.name, ev);
                                        }
                                    }
                                    break;
                            }
                        }

                        Hammer.gestures.Tap = {
                            name: name,
                            index: 100,
                            handler: tapGesture,
                            defaults: {
                                /**
                                 * max time of a tap, this is for the slow tappers
                                 * @property tapMaxTime
                                 * @type {Number}
                                 * @default 250
                                 */
                                tapMaxTime: 250,

                                /**
                                 * max distance of movement of a tap, this is for the slow tappers
                                 * @property tapMaxDistance
                                 * @type {Number}
                                 * @default 10
                                 */
                                tapMaxDistance: 10,

                                /**
                                 * always trigger the `tap` event, even while double-tapping
                                 * @property tapAlways
                                 * @type {Boolean}
                                 * @default true
                                 */
                                tapAlways: true,

                                /**
                                 * max distance between two taps
                                 * @property doubleTapDistance
                                 * @type {Number}
                                 * @default 20
                                 */
                                doubleTapDistance: 20,

                                /**
                                 * max time between two taps
                                 * @property doubleTapInterval
                                 * @type {Number}
                                 * @default 300
                                 */
                                doubleTapInterval: 300
                            }
                        };
                    })('tap');

                    /**
                     * @module gestures
                     */
                    /**
                     * when a touch is being touched at the page
                     *
                     * @class Touch
                     * @static
                     */
                    /**
                     * @event touch
                     * @param {Object} ev
                     */
                    Hammer.gestures.Touch = {
                        name: 'touch',
                        index: -Infinity,
                        defaults: {
                            /**
                             * call preventDefault at touchstart, and makes the element blocking by disabling the scrolling of the page,
                             * but it improves gestures like transforming and dragging.
                             * be careful with using this, it can be very annoying for users to be stuck on the page
                             * @property preventDefault
                             * @type {Boolean}
                             * @default false
                             */
                            preventDefault: false,

                            /**
                             * disable mouse events, so only touch (or pen!) input triggers events
                             * @property preventMouse
                             * @type {Boolean}
                             * @default false
                             */
                            preventMouse: false
                        },
                        handler: function touchGesture(ev, inst) {
                            if (inst.options.preventMouse && ev.pointerType == POINTER_MOUSE) {
                                ev.stopDetect();
                                return;
                            }

                            if (inst.options.preventDefault) {
                                ev.preventDefault();
                            }

                            if (ev.eventType == EVENT_TOUCH) {
                                inst.trigger('touch', ev);
                            }
                        }
                    };

                    /**
                     * @module gestures
                     */
                    /**
                     * User want to scale or rotate with 2 fingers
                     * Preventing the default browser behavior is a good way to improve feel and working. This can be done with the
                     * `preventDefault` option.
                     *
                     * @class Transform
                     * @static
                     */
                    /**
                     * @event transform
                     * @param {Object} ev
                     */
                    /**
                     * @event transformstart
                     * @param {Object} ev
                     */
                    /**
                     * @event transformend
                     * @param {Object} ev
                     */
                    /**
                     * @event pinchin
                     * @param {Object} ev
                     */
                    /**
                     * @event pinchout
                     * @param {Object} ev
                     */
                    /**
                     * @event rotate
                     * @param {Object} ev
                     */

                    /**
                     * @param {String} name
                     */
                    (function(name) {
                        var triggered = false;

                        function transformGesture(ev, inst) {
                            switch (ev.eventType) {
                                case EVENT_START:
                                    triggered = false;
                                    break;

                                case EVENT_MOVE:
                                    // at least multitouch
                                    if (ev.touches.length < 2) {
                                        return;
                                    }

                                    var scaleThreshold = Math.abs(1 - ev.scale);
                                    var rotationThreshold = Math.abs(ev.rotation);

                                    // when the distance we moved is too small we skip this gesture
                                    // or we can be already in dragging
                                    if (scaleThreshold < inst.options.transformMinScale &&
                                        rotationThreshold < inst.options.transformMinRotation) {
                                        return;
                                    }

                                    // we are transforming!
                                    Detection.current.name = name;

                                    // first time, trigger dragstart event
                                    if (!triggered) {
                                        inst.trigger(name + 'start', ev);
                                        triggered = true;
                                    }

                                    inst.trigger(name, ev); // basic transform event

                                    // trigger rotate event
                                    if (rotationThreshold > inst.options.transformMinRotation) {
                                        inst.trigger('rotate', ev);
                                    }

                                    // trigger pinch event
                                    if (scaleThreshold > inst.options.transformMinScale) {
                                        inst.trigger('pinch', ev);
                                        inst.trigger('pinch' + (ev.scale < 1 ? 'in' : 'out'), ev);
                                    }
                                    break;

                                case EVENT_RELEASE:
                                    if (triggered && ev.changedLength < 2) {
                                        inst.trigger(name + 'end', ev);
                                        triggered = false;
                                    }
                                    break;
                            }
                        }

                        Hammer.gestures.Transform = {
                            name: name,
                            index: 45,
                            defaults: {
                                /**
                                 * minimal scale factor, no scale is 1, zoomin is to 0 and zoomout until higher then 1
                                 * @property transformMinScale
                                 * @type {Number}
                                 * @default 0.01
                                 */
                                transformMinScale: 0.01,

                                /**
                                 * rotation in degrees
                                 * @property transformMinRotation
                                 * @type {Number}
                                 * @default 1
                                 */
                                transformMinRotation: 1
                            },

                            handler: transformGesture
                        };
                    })('transform');

                    /**
                     * @module hammer
                     */

                    // AMD export
                    if (typeof define == 'function' && define.amd) {
                        define(function() {
                            return Hammer;
                        });
                        // commonjs export
                    } else if (typeof module !== 'undefined' && module.exports) {
                        module.exports = Hammer;
                        // browser export
                    } else {
                        window.Hammer = Hammer;
                    }

                })(window);
            }, {}],
            32: [function(_dereq_, module, exports) {
                if (!('indexOf' in Array.prototype)) {
                    Array.prototype.indexOf = function(find, i /*opt*/ ) {
                        if (i === undefined) i = 0;
                        if (i < 0) i += this.length;
                        if (i < 0) i = 0;
                        for (var n = this.length; i < n; i++)
                            if (i in this && this[i] === find)
                                return i;
                        return -1;
                    };
                }

                d3 = (function() {
                    var d3 = {
                        version: "3.3.10"
                    }; // semver
                    function d3_class(ctor, properties) {
                        try {
                            for (var key in properties) {
                                Object.defineProperty(ctor.prototype, key, {
                                    value: properties[key],
                                    enumerable: false
                                });
                            }
                        } catch (e) {
                            ctor.prototype = properties;
                        }
                    }

                    d3.map = function(object) {
                        var map = new d3_Map;
                        if (object instanceof d3_Map) object.forEach(function(key, value) {
                            map.set(key, value);
                        });
                        else
                            for (var key in object) map.set(key, object[key]);
                        return map;
                    };

                    function d3_Map() {}

                    d3_class(d3_Map, {
                        has: function(key) {
                            return d3_map_prefix + key in this;
                        },
                        get: function(key) {
                            return this[d3_map_prefix + key];
                        },
                        set: function(key, value) {
                            return this[d3_map_prefix + key] = value;
                        },
                        remove: function(key) {
                            key = d3_map_prefix + key;
                            return key in this && delete this[key];
                        },
                        keys: function() {
                            var keys = [];
                            this.forEach(function(key) {
                                keys.push(key);
                            });
                            return keys;
                        },
                        values: function() {
                            var values = [];
                            this.forEach(function(key, value) {
                                values.push(value);
                            });
                            return values;
                        },
                        entries: function() {
                            var entries = [];
                            this.forEach(function(key, value) {
                                entries.push({
                                    key: key,
                                    value: value
                                });
                            });
                            return entries;
                        },
                        forEach: function(f) {
                            for (var key in this) {
                                if (key.charCodeAt(0) === d3_map_prefixCode) {
                                    f.call(this, key.substring(1), this[key]);
                                }
                            }
                        }
                    });

                    var d3_map_prefix = "\0", // prevent collision with built-ins
                        d3_map_prefixCode = d3_map_prefix.charCodeAt(0);

                    d3.dispatch = function() {
                        var dispatch = new d3_dispatch,
                            i = -1,
                            n = arguments.length;
                        while (++i < n) dispatch[arguments[i]] = d3_dispatch_event(dispatch);
                        return dispatch;
                    };

                    function d3_dispatch() {}

                    d3_dispatch.prototype.on = function(type, listener) {
                        var i = type.indexOf("."),
                            name = "";

                        // Extract optional namespace, e.g., "click.foo"
                        if (i >= 0) {
                            name = type.substring(i + 1);
                            type = type.substring(0, i);
                        }

                        if (type) return arguments.length < 2 ? this[type].on(name) : this[type].on(name, listener);

                        if (arguments.length === 2) {
                            if (listener == null)
                                for (type in this) {
                                    if (this.hasOwnProperty(type)) this[type].on(name, null);
                                }
                            return this;
                        }
                    };

                    function d3_dispatch_event(dispatch) {
                            var listeners = [],
                                listenerByName = new d3_Map;

                            function event() {
                                var z = listeners, // defensive reference
                                    i = -1,
                                    n = z.length,
                                    l;
                                while (++i < n)
                                    if (l = z[i].on) l.apply(this, arguments);
                                return dispatch;
                            }

                            event.on = function(name, listener) {
                                var l = listenerByName.get(name),
                                    i;

                                // return the current listener, if any
                                if (arguments.length < 2) return l && l.on;

                                // remove the old listener, if any (with copy-on-write)
                                if (l) {
                                    l.on = null;
                                    listeners = listeners.slice(0, i = listeners.indexOf(l)).concat(listeners.slice(i + 1));
                                    listenerByName.remove(name);
                                }

                                // add the new listener, if any
                                if (listener) listeners.push(listenerByName.set(name, {
                                    on: listener
                                }));

                                return dispatch;
                            };

                            return event;
                        }
                        // Copies a variable number of methods from source to target.
                    d3.rebind = function(target, source) {
                        var i = 1,
                            n = arguments.length,
                            method;
                        while (++i < n) target[method = arguments[i]] = d3_rebind(target, source, source[method]);
                        return target;
                    };

                    // Method is assumed to be a standard D3 getter-setter:
                    // If passed with no arguments, gets the value.
                    // If passed with arguments, sets the value and returns the target.
                    function d3_rebind(target, source, method) {
                        return function() {
                            var value = method.apply(source, arguments);
                            return value === source ? target : value;
                        };
                    }
                    return d3;
                })();

            }, {}]
        }, {}, [1])
        (1)
});