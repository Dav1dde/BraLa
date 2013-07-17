module minilib.core.ringbuffer;

import core.stdc.string;
import core.atomic;

import std.concurrency;
import std.exception;
import std.string;

/*
Previous names:
PaUtil_InitializeRingBuffer
PaUtil_FlushRingBuffer
PaUtil_GetRingBufferReadAvailable
PaUtil_GetRingBufferWriteAvailable
PaUtil_ReadRingBuffer
PaUtil_WriteRingBuffer
PaUtil_GetRingBufferReadRegions
PaUtil_GetRingBufferWriteRegions
PaUtil_AdvanceRingBufferReadIndex
PaUtil_AdvanceRingBufferWriteIndex
*/

/**
    Single-reader single-writer lock-free ring buffer.

    RingBuffer is a ring buffer used to transport samples between
    different execution contexts (threads, OS callbacks, interrupt handlers)
    without requiring the use of any locks. This only works when there is
    a single reader and a single writer (one thread or callback writes
    to the ring buffer, another thread or callback reads from it).

    The RingBuffer structure manages a ring buffer containing N elements,
    where N must be a power of two. An element may be any size
    (specified in bytes).

    The memory area used to store the buffer elements must be allocated by
    the client prior to calling the ctor and must outlive
    the use of the ring buffer.
*/
struct RingBuffer
{
    /**
        Initialize Ring Buffer to empty state ready to have elements written to it.
        elementCount must be power of 2, throws if not.

        @param elementSizeBytes The size of a single data element in bytes.
        @param elementCount The number of elements in the buffer (must be a power of 2).
        @param dataPtr A pointer to a previously allocated area where the data
            will be maintained. It must be (elementCount * elementSizeBytes) long.
    */
    this(size_t elementSizeBytes, size_t elementCount, void* dataPtr)
    {
        enforce(((elementCount - 1) & elementCount) == 0,
                format("elementCount '%s' is not a power of two.", elementCount));

        this.bufferSize       = elementCount;
        this.buffer           = cast(ubyte*)dataPtr;
        this.bigMask          = (elementCount * 2) - 1;
        this.smallMask        = elementCount - 1;
        this.elementSizeBytes = elementSizeBytes;
    }

    /** Clear buffer to empty. Should only be called when the buffer is not being read or written. */
    void clear()
    {
        this.readIndex = 0;
        this.writeIndex = 0;
    }

    /** Retrieve the number of elements available in the ring buffer for reading. */
    size_t getReadCount() const
    {
        return ((this.writeIndex - this.readIndex) & this.bigMask);
    }

    /** Retrieve the number of elements available in the ring buffer for writing. */
    size_t getWriteCount() const
    {
        return (this.bufferSize - getReadCount());
    }

    /**
        Get address of region(s) from which we can read data.
        If the region is contiguous, size2 will be zero.
        If non-contiguous, size2 will be the size of second region.
        Returns room available to be read or elementCount, whichever is smaller.

        @param elementCount The number of elements desired.
        @param dataPtr1 The address where the first (or only) region pointer will be stored.
        @param sizePtr1 The address where the first (or only) region length will be stored.
        @param dataPtr2 The address where the second region pointer will be stored if
            the first region is too small to satisfy elementCount.
        @param sizePtr2 The address where the second region length will be stored if
            the first region is too small to satisfy elementCount.
        @return The number of elements available for reading.
    */
    size_t getReadRegions(size_t elementCount,
                          void** dataPtr1, size_t* sizePtr1,
                          void** dataPtr2, size_t* sizePtr2)
    {
        size_t index;
        size_t available = getReadCount(); /* doesn't use memory barrier */

        if (elementCount > available)
            elementCount = available;

        /* Check to see if read is not contiguous. */
        index = this.readIndex & this.smallMask;

        if ((index + elementCount) > this.bufferSize)
        {
            /* Write data in two blocks that wrap the buffer. */
            size_t firstHalf = this.bufferSize - index;
            *dataPtr1 = &this.buffer[index * this.elementSizeBytes];
            *sizePtr1 = firstHalf;
            *dataPtr2 = &this.buffer[0];
            *sizePtr2 = elementCount - firstHalf;
        }
        else
        {
            *dataPtr1 = &this.buffer[index * this.elementSizeBytes];
            *sizePtr1 = elementCount;
            *dataPtr2 = null;
            *sizePtr2 = 0;
        }

        /* (read-after-read) => read barrier */
        if (available)
            asm { lfence; }

        return elementCount;
    }

    /**
        Get address of region(s) to which we can write data.
        If the region is contiguous, size2 will be zero.
        If non-contiguous, size2 will be the size of second region.

        @param elementCount The number of elements desired.
        @param dataPtr1 The address where the first (or only) region pointer will be stored.
        @param sizePtr1 The address where the first (or only) region length will be stored.
        @param dataPtr2 The address where the second region pointer will be stored if
            the first region is too small to satisfy elementCount.
        @param sizePtr2 The address where the second region length will be stored if
            the first region is too small to satisfy elementCount.
        @return The room available to be written or elementCount, whichever is smaller.
    */
    size_t getWriteRegions(size_t elementCount,
                           void** dataPtr1, size_t* sizePtr1,
                           void** dataPtr2, size_t* sizePtr2)
    {
        size_t index;
        size_t available = getWriteCount();

        if (elementCount > available)
            elementCount = available;

        /* Check to see if write is not contiguous. */
        index = this.writeIndex & this.smallMask;

        if ((index + elementCount) > this.bufferSize)
        {
            /* Write data in two blocks that wrap the buffer. */
            size_t firstHalf = this.bufferSize - index;
            *dataPtr1 = &this.buffer[index * this.elementSizeBytes];
            *sizePtr1 = firstHalf;
            *dataPtr2 = &this.buffer[0];
            *sizePtr2 = elementCount - firstHalf;
        }
        else
        {
            *dataPtr1 = &this.buffer[index * this.elementSizeBytes];
            *sizePtr1 = elementCount;
            *dataPtr2 = null;
            *sizePtr2 = 0;
        }

        /* (write-after-read) => full barrier */
        if (available)
            atomicFence();

        return elementCount;
    }

    /**
        Advance the read index to the next location to be read.

        @param elementCount The number of elements to advance.
        @return The new position.
    */
    size_t advanceReadIndex(size_t elementCount)
    {
        /**
            Ensure that previous reads (copies out of the ring buffer) are
            always completed before updating (writing) the read index.
            (write-after-read) => full barrier
        */
        atomicFence();
        return this.readIndex = (this.readIndex + elementCount) & this.bigMask;
    }

    /**
        Advance the write index to the next location to be written.
        @param elementCount The number of elements to advance.
        @return The new position.
    */
    size_t advanceWriteIndex(size_t elementCount)
    {
        /**
            ensure that previous writes are seen before we
            update the write index (write after write)
        */
        asm { sfence; }
        return this.writeIndex = (this.writeIndex + elementCount) & this.bigMask;
    }

    /**
        Read data from the ring buffer.

        @param outData The address where the data should be stored.
        @param elementCount The number of elements to be read.
        @return The number of elements read.
    */
    size_t read(void* outData, size_t elementCount)
    {
        size_t size1, size2, numRead;
        void* data1, data2;
        numRead = getReadRegions(elementCount, &data1, &size1, &data2, &size2);

        if (size2 > 0)
        {
            memcpy(outData, data1, size1 * this.elementSizeBytes);
            outData = (cast(ubyte*)outData) + size1 * this.elementSizeBytes;
            memcpy(outData, data2, size2 * this.elementSizeBytes);
        }
        else
        {
            memcpy(outData, data1, size1 * this.elementSizeBytes);
        }

        advanceReadIndex(numRead);
        return numRead;
    }

    /**
        Write data to the ring buffer.

        @param inData The address of new data to write to the buffer.
        @param elementCount The number of elements to be written.
        @return The number of elements written.
    */
    size_t write(void* inData, size_t elementCount)
    {
        size_t size1, size2, numWritten;
        void* data1, data2;
        numWritten = getWriteRegions(elementCount, &data1, &size1, &data2, &size2);

        if (size2 > 0)
        {
            memcpy(data1, inData, size1 * this.elementSizeBytes);
            inData = (cast(ubyte*)inData) + size1 * this.elementSizeBytes;
            memcpy(data2, inData, size2 * this.elementSizeBytes);
        }
        else
        {
            memcpy(data1, inData, size1 * this.elementSizeBytes);
        }

        advanceWriteIndex(numWritten);
        return numWritten;
    }

private:
    size_t bufferSize;        /** Number of elements in FIFO. Power of 2. Set by the ctor. */
    size_t readIndex;         /** Index of next readable element. Set by advanceReadIndex. */
    size_t writeIndex;        /** Index of next writable element. Set by advanceWriteIndex. */
    size_t bigMask;           /** Used for wrapping indices with extra bit to distinguish full/empty. */
    size_t smallMask;         /** Used for fitting indices to buffer. */
    size_t elementSizeBytes;  /** Number of bytes per element. */
    ubyte* buffer;            /** Pointer to the buffer containing the actual data. */
}