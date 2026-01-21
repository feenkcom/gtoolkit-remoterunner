Class {
	#name : #GtRrSyslogParser,
	#superclass : #Object,
	#instVars : [
		'linuxVersion',
		'gtRr',
		'ipAddress',
		'signals',
		'bootSignalIndex',
		'logger'
	],
	#category : 'RemoteRunner-Syslog'
}

{ #category : #accessing }
GtRrSyslogParser >> bootSignal [

	^ signals at: self bootSignalIndex
]

{ #category : #accessing }
GtRrSyslogParser >> bootSignalIndex [
	"Answer the index of the boot signal"
	| index |

	bootSignalIndex ifNotNil: [ ^ bootSignalIndex ].
	index := 0.
	signals doWithIndex: [ :signal :idx |
		(signal messageText beginsWith: 'Linux version') ifTrue:
			[ index := idx ] ].
	bootSignalIndex := index max: 1.
	^ bootSignalIndex
]

{ #category : #accessing }
GtRrSyslogParser >> bootTime [

	^ self bootSignal timestamp
]

{ #category : #accessing }
GtRrSyslogParser >> gtSignalsFor: aView [
	<gtView>

	logger ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Signals';
		priority: 20;
		object: [ logger ];
		view: #gtRecordingsFor:.
]

{ #category : #accessing }
GtRrSyslogParser >> initialize [

	super initialize.
	linuxVersion := '] Linux version'.
	gtRr := '[GtRr] '
]

{ #category : #accessing }
GtRrSyslogParser >> ipAddress [

	^ ipAddress
]

{ #category : #accessing }
GtRrSyslogParser >> ipAddress: anObject [

	ipAddress := anObject
]

{ #category : #accessing }
GtRrSyslogParser >> logger [

	^ logger
]

{ #category : #'private - parsing' }
GtRrSyslogParser >> mmmDdTimestampFrom: line [
	"Read the timestamp from the supplied line.
	Currently assumes that all records are less than 12 months old."
	| today month day time year dateAndTime |

	today := Date today.
	month := line copyFrom: 1 to: 3.
	day := (line copyFrom: 5 to: 6) trimLeft asNumber.
	year := today year.
	time := Time fromString: (line copyFrom: 8 to: 15).
	dateAndTime := DateAndTime
		date: (Date year: year month: month day: day)
		time: time.
	dateAndTime monthIndex > today monthIndex ifTrue:
		[ dateAndTime := DateAndTime 
			date: (Date year: year-1 month: month day: day)
			time: time ].
	^ dateAndTime.
]

{ #category : #parsing }
GtRrSyslogParser >> parseFile: aFileReference [

	^ aFileReference asFileReference readStreamDo: [ :stream |
		self parseStream: stream ].
]

{ #category : #'private - parsing' }
GtRrSyslogParser >> parseLine: line [ 
	| index |

	(index := line indexOfSubCollection: linuxVersion) > 0 ifTrue:
		[ ^ self signalFromLine: line index: index+2 ]
	ifFalse: [ (index := line indexOfSubCollection: gtRr) > 0 ifTrue:
		[ ^ self signalFromLine: line index: index+7 ] ].
	^ nil
]

{ #category : #parsing }
GtRrSyslogParser >> parseStream: stream [ 

	signals := Array streamContents: [ :resultStream |
		[ stream atEnd ] whileFalse:
			 [ (self parseLine: stream nextLine) ifNotNil:
				[ :signal | resultStream nextPut: signal ] ] ].
	logger := MemoryLogger new basicRecordings: signals.
]

{ #category : #filtering }
GtRrSyslogParser >> selectCurrentBoot [
	"Remove signals from previous boots"
	| index |

	index := self bootSignalIndex.
	index = 1 ifTrue: [ ^ self ].
	signals := signals copyFrom: index to: signals size.
	bootSignalIndex := 1.
]

{ #category : #'private ' }
GtRrSyslogParser >> signalFromLine: line index: index [ 

	^ GtRrSyslogSignal new
		basicTimestamp: (self timestampFrom: line);
		messageText: (line copyFrom: index to: line size);
		ipAddress: ipAddress.
]

{ #category : #accessing }
GtRrSyslogParser >> signals [

	^ signals
]

{ #category : #'private - parsing' }
GtRrSyslogParser >> timestampFrom: line [
	"Read the timestamp from the supplied line"

	^ line first isDigit
		ifTrue: [ self yyyyMmDdTimestampFrom: line ]
		ifFalse: [ self mmmDdTimestampFrom: line ]
]

{ #category : #'private - parsing' }
GtRrSyslogParser >> yyyyMmDdTimestampFrom: line [
	"Read the timestamp from the supplied line"
	| timestampString |

	timestampString := line readStream upTo: Character space.
	^ DateAndTime readFrom: timestampString readStream.
]
