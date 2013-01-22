// This file is part of Odg.

//     Odg is free software: you can redistribute it and/or modify
//     it under the terms of the GNU General Public License as published by
//     the Free Software Foundation, either version 3 of the License, or
//     (at your option) any later version.

//     Odg is distributed in the hope that it will be useful,
//     but WITHOUT ANY WARRANTY; without even the implied warranty of
//     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//     GNU General Public License for more details.

//     You should have received a copy of the GNU General Public License
//     along with Odg.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2013 Jukka-Pekka Partanen (jukpart@gmail.com)


// custom message source class must implement this interface
public interface MessageSourceIF: Object {
	
    // start() method must start a separate thread or use some another
    // asynchronous scheme
	public abstract void start(); 
	public abstract void initialize();
	public abstract void clear_alarm();
}

// an instance derived from this class is passed to GaugeControl which
// creates new message source and starts it
public abstract class MessageSourceFactory {
	public abstract MessageSourceIF? create();
}


