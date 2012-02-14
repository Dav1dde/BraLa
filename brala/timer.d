module brala.timer;

private import std.datetime : Clock;
public import core.time : TickDuration;


struct Timer {
    private TickDuration stime;
    package bool _paused = false;
    package bool _started = false;
       
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
        _paused = !paused;
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

struct FPSCounter {
    Timer timer;
    alias timer this;
    
    uint frames = 0;
    
    void update() {
        if(!_started) {
            start();
        }
        frames++;
    }
    
    @disable void pause();
    @disable void resume();
    
    @property float fps() {
        return frames/(timer.get_time().to!("seconds", float));
    }
}