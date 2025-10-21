Class {
	#name : #GtRrExternalMemoryAndFinalizationStatsEntry,
	#superclass : #Object,
	#instVars : [
		'count',
		'time',
		'start',
		'slowest',
		'name'
	],
	#category : #'RemoteRunner-Analysis'
}

{ #category : #'instance creation' }
GtRrExternalMemoryAndFinalizationStatsEntry class >> leJsonV4AttributeMapping [

	^ {
		#count -> #count.
		#time -> #time.
		#start -> #start.
		#slowest -> #slowest.
		#name -> #name. }
]

{ #category : #'instance creation' }
GtRrExternalMemoryAndFinalizationStatsEntry class >> leJsonV4Name [

	^ #gtExternalMemoryStatsEntry
]

{ #category : #'instance creation' }
GtRrExternalMemoryAndFinalizationStatsEntry class >> name: aString [

	^ self new name: aString
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStatsEntry >> average [
	"Answer the average time in seconds"

	^ time / 1000000.0 / (count max: 1)
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStatsEntry >> count [

	^ count
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStatsEntry >> count: anObject [
	count := anObject
]

{ #category : #operations }
GtRrExternalMemoryAndFinalizationStatsEntry >> endCycle [
	| cycleTime |
	
	start ifNil:
		[ [ self error: 'Inconsistent end finalization state' ] fork.
		^ self ].
	count := count + 1.
	cycleTime := Time microsecondClockValue - start.
	cycleTime > slowest ifTrue: [ slowest := cycleTime ].
	time := time + cycleTime.
	start := nil.
]

{ #category : #initialization }
GtRrExternalMemoryAndFinalizationStatsEntry >> initialize [

	super initialize.
	self restart.
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStatsEntry >> name [
	^ name
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStatsEntry >> name: anObject [
	name := anObject
]

{ #category : #operations }
GtRrExternalMemoryAndFinalizationStatsEntry >> reportStringFrom: startTime [
	| percentage seconds elapsedTime elapsedSeconds |

	seconds := (time / 1000000.0) rounded.
	elapsedTime := DateAndTime now - startTime.
	elapsedSeconds := elapsedTime asSeconds.
	percentage := elapsedSeconds > 0
		ifTrue: [ (seconds / elapsedSeconds) * 100.0 ]
		ifFalse: [ 0 ].
	^ String streamContents: [ :stream |
		stream
			<< 'Count              : ';
				print: count; cr;
			<< 'Average (s)        : ';
				<< (self average printShowingDecimalPlaces: 3); cr;
			<< 'Slowest (s)        : ';
				<< ((slowest / 1000000.0) printShowingDecimalPlaces: 3); cr;
			<< 'Cumulative time (s): ';
				print: seconds; cr;
			<< '%                  : ';
				<< (percentage printShowingDecimalPlaces: 1); cr ].
]

{ #category : #initialization }
GtRrExternalMemoryAndFinalizationStatsEntry >> restart [

	count := 0.
	time := 0.
	slowest := 0.
	start := nil.
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStatsEntry >> seconds [

	^ time / 1000000.0
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStatsEntry >> slowest [

	^ slowest
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStatsEntry >> slowest: anObject [
	slowest := anObject
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStatsEntry >> start [
	^ start
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStatsEntry >> start: anObject [
	start := anObject
]

{ #category : #operations }
GtRrExternalMemoryAndFinalizationStatsEntry >> startCycle [

	start ifNotNil:
		[ [ self error: 'Inconsistent finalization state' ] fork.
		^ self ].
	start := Time microsecondClockValue.
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStatsEntry >> time [

	^ time
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStatsEntry >> time: anObject [
	time := anObject
]
