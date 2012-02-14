module brala.timer;

private {
    import std.datetime : Clock;
    import core.time : TickDuration;
}

struct Timer {
    private TickDuration stime = 0;
    private bool _paused = false;
    private bool _started = false;
       
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
    
    TickDuration get_time() {
        if(_started) {
            if(_paused) {
                return stime;
            else {
                return Clock.currSystemTick() - stime;
            }
        } else {
            return TickDuration(0);
        }
    }
    
}