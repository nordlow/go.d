import std.datetime;
import std.algorithm;
import std.range;
import std.stdio;
import std.concurrency : Thread;
import jin.go;

import vibe.core.core : workerThreadCount;

void testFiberCalls()
{
}

void testCalls(int taskCount = 10_000)
{
    StopWatch timer;
    timer.start();

    static auto writing()
    {
        // writeln(Thread.getThis().id);
    }

    auto inputs = taskCount.iota.map!(i => go!writing).array;
    // foreach (i; inputs)
    // {
    //     writeln(i);
    // }

    timer.stop();

    writeln("jin.go: ", timer.peek.msecs);
}

/** Benchmark function that will send `dataCount` number of messages from
    `taskCount` number of tasks.
*/
void testCollection(int taskCount = 1_000)
{
    writeln("workerThreadCount:", workerThreadCount);

    enum int dataCount = 1_000;

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

void main()
{
    testCalls();
    testCollection();
}
