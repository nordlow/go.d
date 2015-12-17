import std.stdio;
import std.concurrency;
import std.conv;
import std.typecons;
import std.datetime;
import std.variant;
import std.range;
import jin.go;

const int iterations = 100000;
const int writersCount = 32;
const int readersCount = writersCount;

/*
synchronized class SyncQ {
	private shared int[] data;
	void push( int v ) {
		data ~= v;
	}
	auto eat( ) {
		if( data.length == 0 ) return Nullable!int.init;
		auto v = data[0];
		data = data[ 1 .. $ ];
		return Nullable!int( cast(int) v );
	}
}

shared SyncQ sq;

void one() {
	StopWatch timer;
	timer.start();

	sq = new SyncQ;

	for( int j = writersCount ; j > 0 ; --j ) {
		spawn({
			for( int i = iterations - 1 ; i >= 0 ; --i ) {
				writeln( ">",i );
				sq.push( i );
			}
		});
	}

	for( int j = readersCount ; j > 0 ; --j ) {
		spawn({
			while( true ) {
				auto v = sq.eat();
				writeln( "<",v );
				if( v.isNull ) continue;
				if( v == 0 ) break;
			}
			ownerTid.send( 0L );
		});
	}

	for( int j = readersCount ; j > 0 ; --j ) {
		receiveOnly!long;
	}

	timer.stop();

	writeln( "std.concurency milliseconds=" , timer.peek.msecs );
}

void two() {
	StopWatch timer;
	timer.start();

	Output readers;
	Input writers;

	for( int j = writersCount ; j > 0 ; --j ) {
		writers ~= go( ( owner ) {
			for( int i = iterations - 1 ; i >= 0 ; --i ) {
				owner.push( i );
			}
		} );
	}

	for( int j = readersCount ; j > 0 ; --j ) {
		readers ~= go( ( owner ) {
			while( true ) {
				auto v = owner.take.get!int;
				if( v == 0 ) owner.push( 0L );
			}
		} );
	}

	auto childs = Input( writers ~ readers );

	for( int j = readersCount ; j > 0 ; --j ) {
		while( true ) {
			auto msg = childs.take;
			auto proxy = msg.peek!int;
			if( proxy !is null ) {
				readers.push( *proxy );
				continue;
			}
			auto val = msg.get!long;
			if( !val ) break;
		}
	}

	timer.stop();

	writeln( "jin.go milliseconds=" , timer.peek.msecs );
}
*/

void one() {
	StopWatch timer;
	timer.start();

	for( int j = writersCount ; j > 0 ; --j ) {
		spawn({
			for( int i = iterations - 1 ; i >= 0 ; --i ) {
				ownerTid.send( i );
			}
		});
	}

	for( int j = writersCount ; j > 0 ; --j ) {
		while( receiveOnly!int ) {}
	}

	timer.stop();

	writeln( "std.concurency milliseconds=" , timer.peek.msecs );
}

void two() {
	StopWatch timer;
	timer.start();

	Input childs;

	for( int j = writersCount ; j > 0 ; --j ) {
		childs ~= go(( owner ){
			for( int i = iterations - 1 ; i >= 0 ; --i ) {
				owner.push( i );
			}
		});
	}

	for( int j = writersCount ; j > 0 ; --j ) {
		while( childs.take.get!int ) {}
	}

	timer.stop();

	writeln( "jin.go milliseconds=" , timer.peek.msecs );
}

void main() {
	writeln( "iterations=" , iterations );
	writeln( "writers =" , writersCount );
	writeln( "readers =" , readersCount );
	one();
	two();
}
