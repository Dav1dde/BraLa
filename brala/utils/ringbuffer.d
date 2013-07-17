module brala.utils.ringbuffer;

private {
    import mrb = minilib.core.ringbuffer;

    import std.exception : enforceEx;
    import core.thread : Thread;
    import core.time : msecs;
    import core.memory : GC;

    import brala.utils.memory : calloc, free;
}

public import brala.utils.exception : RingBufferException;


/// Abstraction of a Single-reader single-writer lock-free ring buffer,
/// found in minilib.core.ringbuffer
class RingBuffer(T) {
    alias Type = T;
    protected void* buffer;
    protected mrb.RingBuffer ringbuffer;
    protected immutable bool gc_memory;


    this(size_t elements, bool use_gc=true) {
        enforceEx!RingBufferException(elements.is_power_of_two, "elements is not a power of two");

        gc_memory = use_gc;
        buffer = calloc(elements, Type.sizeof);
        if(use_gc) {
            GC.addRange(buffer, elements*Type.sizeof);
        }

        scope(failure) {
            if(use_gc) {
                GC.removeRange(buffer);
            }

            buffer.free();
        }

        ringbuffer = mrb.RingBuffer(Type.sizeof, elements, buffer);
    }

    void clear() {
        ringbuffer.clear();
    }

    @property const
    size_t read_count() {
        return ringbuffer.getReadCount();
    }

    @property const
    size_t write_count() {
        return ringbuffer.getWriteCount();
    }

    /// Use with care, might deadlock your application!
    Type read_one() {
        Type into;
        while(ringbuffer.read(&into, 1) != 1) { Thread.sleep(100.msecs); }
        return into;
    }

    Type[] read(size_t n) {
        Type[] into = new Type[n];
        size_t r = ringbuffer.read(into.ptr, n);
        return into[0..r];
    }

    /// Use with care, might deadlock your application!
    Type[] read_exactly(size_t n) {
        Type[] into = new Type[n];

        size_t read = 0;
        while(true) {
            read += ringbuffer.read(into.ptr+read, n-read);
            if(read == n) break;
            Thread.sleep(100.msecs);
        }

        return into;
    }

    Type[] read_all() {
        return read(read_count);
    }

    /// Use with care, might deadlock your application!
    void write_one(Type t) {
        while(ringbuffer.write(&t, 1) != 1) { Thread.sleep(100.msecs); }
    }

    size_t write(Type[] t...) {
        return ringbuffer.write(t.ptr, t.length);
    }

    /// Use with care, might deadlock your application!
    void write_exactly(Type[] t...) {
        size_t written = 0;
        while(true) {
            written += ringbuffer.write(t.ptr+written, t.length-written);
            if(written == t.length) break;
            Thread.sleep(100.msecs);
        }
    }

    ~this() {
        if(gc_memory) {
            GC.removeRange(buffer);
        }

        buffer.free();
    }
}

bool is_power_of_two(size_t num) {
    return num == 0 || !(num & (num-1));
}