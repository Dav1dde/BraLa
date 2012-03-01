module nbt.list;

extern(C):

/*
 * Represents a single entry in the list. This must be embedded in your linked
 * structure.
 */
struct list_head {
    list_head *blink; /* back  link */
    list_head *flink; /* front link */
}
