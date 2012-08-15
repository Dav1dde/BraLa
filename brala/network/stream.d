module brala.network.stream;

private {
    import std.stream : Stream, FilterStream, BufferedStream;
}

class AESStream(AES) : FilterStream {
    protected ubyte[] read_buffer; // stores *decrypted* data
    protected size_t read_buffer_pos = 0;
    protected size_t read_buffer_len = 0;

    protected ubyte[] write_buffer;
    protected size_t write_buffer_pos = 0;
    protected size_t write_buffer_len = 0;
    
    enum size_t DEFAULT_BUFFER_SIZE = 4096;
    
    protected AES aes;

    this(Stream stream, AES aes, size_t buffer_size = DEFAULT_BUFFER_SIZE) {
        super(stream);
        
        this.aes = aes;
        this.read_buffer = new ubyte[buffer_size];
        this.write_buffer = new ubyte[buffer_size];
    }

    override size_t readBlock(void* result, size_t size) {
        if(size == 0) return 0;
        ubyte* outbuf = cast(ubyte*)result;

        Lrbstart:

        if(read_buffer_len >= size) {
            outbuf[0..size] = read_buffer[read_buffer_pos..(read_buffer_pos + size)];
            read_buffer_pos += size;
            read_buffer_len -= size;
            return size;     
        }

        size_t readsize = read_buffer_len;
        if(readsize) {
            outbuf[0..readsize] = read_buffer[read_buffer_pos..(read_buffer_pos + readsize)];
            read_buffer_pos += readsize;
            read_buffer_len = 0;
            return readsize;
        } else {
            size_t r = super.readBlock(read_buffer.ptr, read_buffer.length);
            if(r == 0) return 0;
            ubyte[] decrypted = aes.decrypt(read_buffer.ptr, r);
            read_buffer[0..decrypted.length] = decrypted;
            read_buffer_len = decrypted.length;
            read_buffer_pos = 0;

            goto Lrbstart;
        }
    }

    override size_t writeBlock(const void* buffer, size_t size) {
        if(size == 0) return 0;
        const(ubyte)* inbuf = cast(const(ubyte)*)buffer;

        Lwbstart:
        
        size_t remaining = write_buffer.length - write_buffer_len;
        if(remaining >= size) {
            write_buffer[write_buffer_pos..(write_buffer_pos + size)] = inbuf[0..size];
            write_buffer_pos += size;
            write_buffer_len += size;
            return size;
        } else if(remaining > 0) {
            write_buffer[write_buffer_pos..(write_buffer_pos + remaining)] = inbuf[0..remaining];
            write_buffer_pos += remaining;
            write_buffer_len += remaining;
            flush();
            return remaining;
        } else {
            flush();
            goto Lwbstart;
        }
    }

    override void flush() {
        if(write_buffer_len) {
            ubyte[] encrypted = aes.encrypt(write_buffer.ptr, write_buffer_len);
            source.writeExact(encrypted.ptr, write_buffer_len);
            write_buffer_len = 0;
            write_buffer_pos = 0;
        }

        super.flush();
    }
}

