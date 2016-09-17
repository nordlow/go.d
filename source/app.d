import std.datetime;
import std.algorithm;
import std.range;
import std.stdio;
import std.concurrency : Thread;
import jin.go;

/** Benchmark function that will send `dataCount` number of messages from
    `taskCount` number of tasks.
*/
void main()
{
    enum int dataCount = 1000;
    enum int taskCount = 1000;

    StopWatch timer;
    timer.start();

    struct Data
    {
        int value;
    }

    static auto nothrow writing()
    {
        Thread.getThis();
        return dataCount.iota.map!Data;
    }

    auto inputs = taskCount.iota
                           .map!(i => go!writing)
                           .array
                           .Inputs!Data;
    foreach (i; inputs)
    {
        writeln(i);
    }

    timer.stop();

    writeln("jin.go: ", timer.peek.msecs);
}
