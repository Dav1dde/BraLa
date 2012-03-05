module brala.timer;

private import std.datetime : Clock;
public import core.time : TickDuration;


class Timer {
    private TickDuration stime;
    package bool _paused = false;
    package bool _started = false;
    
    this() {}
    
    @property bool paused() {
        return _paused;
    }
    
    @property bool started() {
        return _started;
    }
    
    void start() {
        _started = true;
        stime = Clock.currSystemTick();
    }
    
    void pause() {
        _paused = !_paused;
        stime = Clock.currSystemTick() - stime;
    }
    alias pause resume;
    
    TickDuration stop() {       
        TickDuration t = get_time();
        
        _started = false;
        _paused = false;
        stime = TickDuration(0);
        
        return t;
    }
    
    TickDuration get_time() {
        if(_started) {
            if(_paused) {
                return stime;
            } else {
                return Clock.currSystemTick() - stime;
            }
        } else {
            return TickDuration(0);
        }
    }
    
}

class FPSCounter : Timer {
    uint frames = 0;
    
    this() {}
    
    void update() {
        if(!_paused) {
            if(!_started) {
                start();
            }
            frames++;
        }
    }
    
    @property float fps() {
        return frames/(get_time().to!("seconds", float));
    }
}