Class {
	#name : #GtRrSignalSerializationExamples,
	#superclass : #Object,
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrSignalSerializationExamples >> gtRrResultProcessingErrorAnnouncement [
	<gtExample>
	| signal serialized deserialized reader errorInfo signals |

	errorInfo := { 'a' -> 1. } asDictionary.
	signal := GtRrResultProcessingErrorAnnouncement new
		workerAttributes: Dictionary new;
		workerId: 'a-b-c-d';
		errorInfo: errorInfo;
		remoteAddressString: '1.2.3.4';
		workingDirectory: '/a/d';
		yourself.
	serialized := String streamContents: [ :stream |
		signal printOneLineOn: stream ].
	reader := GtBeaconJsonLogReader new.
	signals := OrderedCollection new.
	deserialized := reader processLine: serialized into: signals.
	self assert: deserialized class equals: GtRrResultProcessingErrorAnnouncement.
	self assert: deserialized workerId equals: 'a-b-c-d'.
	self assert: deserialized errorInfo equals: errorInfo.
	self assert: deserialized remoteAddressString equals: '1.2.3.4'.
	self assert: deserialized workingDirectory equals: '/a/d'.
]

{ #category : #examples }
GtRrSignalSerializationExamples >> gtRrStampErrorSignal [
	<gtExample>
	| frame stampError signal dictionary deserialized |

	frame := StampErrorFrame new
		message: 'stamp error message';
		body: 'stamp error body';
		yourself.
	frame headers
		at: #contentType put: 'text/plain';
		at: #custom put: 'value'.
	stampError := StampError new
		errorFrame: frame;
		yourself.
	signal := GtRrStampErrorSignal fromStampError: stampError.
	dictionary := signal asGtJsonLogDictionary.
	deserialized := GtRrStampErrorSignal fromGtJsonDictionary: dictionary.
	self assert: deserialized class equals: GtRrStampErrorSignal.
	self assert: deserialized message equals: 'stamp error message'.
	self assert: deserialized headers equals: frame headers.
	self assert: deserialized body equals: 'stamp error body'.
	^ deserialized
]
