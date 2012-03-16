module brala.network.queue;

private {
    import std.array : empty, front, back, popFront, popBack;
    
    import brala.network.packets.types : IPacket;
}

class PacketQueue {
    protected Object _lock;
    
    IPacket[] packets;
    
    this() {
        _lock = new Object();
    }
    
    void add(IPacket packet) {
        synchronized(_lock) packets ~= packet;
    }
    
    bool empty() {
        return packets.empty;
    }
    
    IPacket pop_front() {
        IPacket p;
        
        synchronized(_lock) {
            p = packets.front;
            packets.popFront();
        }
        
        return p;
    }
    
    IPacket pop_back() {
        IPacket p;
        
        synchronized(_lock) {
            p = packets.back;
            packets.popBack();
        }
        
        return p;
    }
    
    int opApply(int delegate(IPacket packet) dg) {
        int result;

        while(!packets.empty) {
            result = dg(pop_front());
            if(result) break;
        }
        
        return result;
    }
}