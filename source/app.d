import std.datetime;
import std.algorithm;
import std.range;
import std.stdio;
import std.concurrency : Thread;
import jin.go;

import vibe.core.core : workerThreadCount;

/** Benchmark function that will send `dataCount` number of messages from
    `taskCount` number of tasks.
*/
void main()
{
    writeln(workerThreadCount);

    enum int dataCount = 1_000;
    enum int taskCount = 1_000;

    StopWatch timer;
    timer.start();

    struct Data
    {
        int value;
    }

    static auto writing() @safe pure nothrow @nogc
    {
        // writeln(Thread.getThis().id);
        return dataCount.iota.map!Data;
    }

    auto inputs = taskCount.iota
                           .map!(i => go!writing)
                           .array
                           .Inputs!Data;
    foreach (i; inputs)
    {
        // writeln(i);
    }

    timer.stop();

    writeln("jin.go: ", timer.peek.msecs);
}
