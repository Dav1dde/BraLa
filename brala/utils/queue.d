module brala.utils.queue;

private {
    import std.array : empty, front, back, popFront, popBack;
    
    import brala.network.packets.types : IPacket;
}

class Queue(type) {
    protected Object _lock;
    
    type[] data;
    
    this() {
        _lock = new Object();
    }
    
    void add(type d) {
        synchronized(_lock) data ~= d;
    }
    
    bool empty() {
        return data.empty;
    }
    
    type pop_front() {
        type p;
        
        synchronized(_lock) {
            p = data.front;
            data.popFront();
        }
        
        return p;
    }
    
    type pop_back() {
        type p;
        
        synchronized(_lock) {
            p = data.back;
            data.popBack();
        }
        
        return p;
    }
    
    int opApply(int delegate(type d) dg) {
        int result;

        while(!data.empty) {
            result = dg(pop_front());
            if(result) break;
        }
        
        return result;
    }
}

alias Queue!(IPacket) PacketQueue;