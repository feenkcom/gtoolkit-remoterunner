"
GtRrRunnerLogReader reads a log file typically created by a headless remote runner and loads signals that respond to `#initializeFromTimestamp:andData:`.

```
GtRrRunnerLogReader new
	filename: 'remoteRunner.log';
	load
```
"
Class {
	#name : #GtRrRunnerLogReader,
	#superclass : #Object,
	#instVars : [
		'filename',
		'signals',
		'strictMode'
	],
	#category : #'RemoteRunner-Analysis'
}

{ #category : #accessing }
GtRrRunnerLogReader >> filename [
	^ filename
]

{ #category : #accessing }
GtRrRunnerLogReader >> filename: anObject [
	filename := anObject
]

{ #category : #accessing }
GtRrRunnerLogReader >> gtSignalsFor: aView [
	<gtView>

	^ aView forward
		title: 'Signals';
		priority: 10;
		object: [ self memoryLogger ];
		view: #gtRecordingsFor:
]

{ #category : #initialization }
GtRrRunnerLogReader >> initialize [

	super initialize.
	strictMode := true.
]

{ #category : #actions }
GtRrRunnerLogReader >> load [

	signals := OrderedCollection new.
	filename asFileReference readStreamDo: [ :stream |
		[ stream atEnd ] whileFalse:
			[ self processLine: stream nextLine ] ].
	^ signals
]

{ #category : #accessing }
GtRrRunnerLogReader >> memoryLogger [
	"Answer a MemoryLogger loaded with the receiver's signals.
	Generally for debugging purposes."

	^ MemoryLogger new
		basicRecordings: self signals.
]

{ #category : #private }
GtRrRunnerLogReader >> processLine: aString [
	| words date cls data |

	words := aString splitOn: Character space.
	"Minimum is date, class, signal type"
	words size < 3 ifTrue: [ ^ self ].
	(self shouldLoad: words) ifFalse: [ ^ self ].

	[ date := DateAndTime readFrom: words first readStream ]
		on: Error
		do: [ :ex | ^ self ].
	cls := Smalltalk classOrTraitNamed: words second asSymbol.
	cls ifNil: [ ^ self ].
	(cls canUnderstand: #initializeFromTimestamp:andData:) ifFalse: [ ^ self ].
	(self shouldLoad: words) ifFalse: [ ^ self ].

	data := (aString splitOn: ' | ') allButFirst.
	[ signals add: (cls new initializeFromTimestamp: date andData: data) ]
		on: Error
		do: [ :ex | strictMode ifTrue: [ ex pass ] ].
]

{ #category : #private }
GtRrRunnerLogReader >> shouldLoad: words [
	"Give subclasses a chance to add criteria"
	
	^ true
]

{ #category : #accessing }
GtRrRunnerLogReader >> signals [

	^ signals ifNil: [ signals := self load ].
]

{ #category : #accessing }
GtRrRunnerLogReader >> strictMode [
	^ strictMode
]

{ #category : #accessing }
GtRrRunnerLogReader >> strictMode: anObject [
	strictMode := anObject
]
