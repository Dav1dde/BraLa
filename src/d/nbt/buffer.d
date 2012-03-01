module nbt.buffer;

/*
 * -----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * Lukas Niederbremer <webmaster@flippeh.de> and Clark Gaebel <cg.wowus.cg@gmail.com>
 * wrote this file. As long as you retain this notice you can do whatever you
 * want with this stuff. If we meet some day, and you think this stuff is worth
 * it, you can buy us a beer in return.
 * -----------------------------------------------------------------------------
 */

extern(C):
 
/*
 * A buffer is 'unlimited' storage for raw data. As long as buffer_append is
 * used to add data, it will automatically resize to make room. To read the
 * data, just access `data' directly.
 */
struct buffer {
    ubyte* data;         /* You can access the buffer's raw bytes through this pointer */
    size_t len;          /* Only accesses in the interval [data, data + len) are defined */
    size_t cap;          /* Internal use. The allocated size of the buffer. */
};


/*
 * Frees all memory associated with the buffer. The same buffer may be freed
 * multiple times without consequence.
 */
void buffer_free(buffer* b);

/*
 * Ensures there's enough room in the buffer for at least `reserved_amount'
 * bytes. Returns non-zero on failure. If such a failure occurs, the buffer
 * is deallocated and set to one which can be passed to buffer_free. Any other
 * usage is undefined.
 */
int buffer_reserve(buffer* b, size_t reserved_amount);

/*
 * Copies `n' bytes from `data' into the buffer. Returns non-zero if an
 * out-of-memory failure occured. If such a failure occurs, further usage of the
 * buffer results in undefined behavior.
 */
int buffer_append(buffer* b, const(void)* data, size_t n);