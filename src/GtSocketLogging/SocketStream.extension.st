Extension { #name : #SocketStream }

{ #category : #'*GtSocketLogging' }
SocketStream >> flush [
	"If the other end is connected and we have something
	to send, then we send it and reset the outBuffer."

	((outNextToWrite > 1) and: [socket isOtherEndClosed not])
		ifTrue: [
			(GtSocketHandleAnnouncement socketStream: self)
				bufferSize: outNextToWrite - 1;
				buffer: outBuffer;
				message: 'SocketStream>>flush pre';
				emit.
			[ socket sendData: outBuffer count: outNextToWrite - 1]
				on: ConnectionTimedOut
				do: [:ex | shouldSignal ifFalse: ["swallow"]].
			outNextToWrite := 1.
			(GtSocketHandleAnnouncement 
				socketStream: self 
				bufferSize: nil
				message: 'SocketStream>>flush post') emit.
			]
]

{ #category : #'*GtSocketLogging' }
SocketStream >> nextPutAllFlush: aCollection [
	"Put a String or a ByteArray onto the stream.
	You can use this if you have very large data - it avoids
	copying into the buffer (and avoids buffer growing)
	and also flushes any other pending data first."

	| toPut |
	toPut := binary ifTrue: [aCollection asByteArray] ifFalse: [aCollection asString].
	self flush. "first flush pending stuff, then directly send"
	(GtSocketHandleAnnouncement 
		socketStream: self 
		buffer: aCollection
		message: 'SocketStream>>nextPutAllFlush: pre') emit.
	socket isOtherEndClosed ifFalse: [
		[socket sendData: toPut count: toPut size]
			on: ConnectionTimedOut
			do: [:ex | shouldSignal ifFalse: ["swallow"]]].
	(GtSocketHandleAnnouncement 
		socketStream: self 
		buffer: aCollection
		message: 'SocketStream>>nextPutAllFlush: post') emit.

]

{ #category : #'*GtSocketLogging' }
SocketStream >> receiveAvailableData [
	"Receive available data (as much as fits in the inBuffer)
	but not waiting for more to arrive.
	Return the position in the buffer where the
	new data starts, regardless if anything
	was read, see #adjustInBuffer."
	
	(GtSocketHandleAnnouncement 
		socketStream: self 
		bufferSize: nil
		message: 'SocketStream>>receiveAvailableData pre') emit.
	recentlyRead := socket receiveAvailableDataInto: inBuffer startingAt: inNextToWrite.
	(GtSocketHandleAnnouncement 
		socketStream: self 
		buffer: inBuffer
		message: 'SocketStream>>receiveAvailableData post') emit.
	^self adjustInBuffer: recentlyRead
]

{ #category : #'*GtSocketLogging' }
SocketStream >> receiveData [
	"Receive data with timeout if it has been set.
	If shouldSignal is false we use the Socket methods
	that swallow those Exceptions, if it is true the
	caller will have to handle those Exceptions.
	Return the position in the buffer where the
	new data starts, regardless if anything
	was read, see #adjustInBuffer."
	
	(GtSocketHandleAnnouncement 
		socketStream: self 
		bufferSize: nil
		message: 'SocketStream>>receiveData pre') emit.
	recentlyRead := shouldSignal ifTrue: [
		self shouldTimeout ifTrue: [
				socket receiveDataSignallingTimeout: timeout
					into: inBuffer startingAt: inNextToWrite]
			ifFalse: [
				socket receiveDataSignallingClosedInto: inBuffer
					startingAt: inNextToWrite]]
				ifFalse: [
		self shouldTimeout ifTrue: [
			"This case is tricky, if it times out and is swallowed
			how does other methods calling this method repeatedly
			get to know that? And what should they do?"
				socket receiveDataTimeout: timeout
					into: inBuffer startingAt: inNextToWrite]
			ifFalse: [
				socket receiveDataInto: inBuffer
					startingAt: inNextToWrite]].
	(GtSocketHandleAnnouncement socketStream: self)
		buffer: (inBuffer copyFrom: inNextToWrite to: inNextToWrite + recentlyRead - 1);
		message: 'SocketStream>>receiveData post';
		emit.
	^self adjustInBuffer: recentlyRead
]

{ #category : #'*GtSocketLogging' }
SocketStream >> receiveDataIfAvailable [
	"Only used to check that there really is data to read
	from the socket after it signals dataAvailable.
	It has been known to signal true and then still
	not have anything to read. See also isDataAvailable.
	Return the position in the buffer where the
	new data starts, regardless if anything
	was read, see #adjustInBuffer."

	(GtSocketHandleAnnouncement 
		socketStream: self 
		bufferSize: nil
		message: 'SocketStream>>receiveDataIfAvailable pre') emit.
	recentlyRead := socket receiveSomeDataInto: inBuffer startingAt: inNextToWrite.
	(GtSocketHandleAnnouncement 
		socketStream: self 
		buffer: inBuffer
		message: 'SocketStream>>receiveDataIfAvailable post') emit.
	^self adjustInBuffer: recentlyRead
]
