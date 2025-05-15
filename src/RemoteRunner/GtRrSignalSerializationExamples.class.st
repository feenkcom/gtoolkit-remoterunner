Class {
	#name : #GtRrSignalSerializationExamples,
	#superclass : #Object,
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrSignalSerializationExamples >> gtRrResultProcessingErrorAnnouncement [
	<gtExample>
	| signal serialized deserialized reader |

	signal := GtRrResultProcessingErrorAnnouncement new
		workerAttributes: Dictionary new;
		workerId: 'a-b-c-d';
		errorDetails: 'ed';
		remoteAddressString: '1.2.3.4';
		workingDirectory: '/a/d';
		yourself.
	serialized := String streamContents: [ :stream |
		signal printOneLineOn: stream ].
	reader := GtRrRunnerLogReader new.
	deserialized := reader processLine: serialized.
	self assert: deserialized class equals: GtRrResultProcessingErrorAnnouncement.
	self assert: deserialized workerId equals: 'a-b-c-d'.
	self assert: deserialized errorDetails equals: 'ed'.
	self assert: deserialized remoteAddressString equals: '1.2.3.4'.
	self assert: deserialized workingDirectory equals: '/a/d'.
]
