Class {
	#name : #GtRrSyslogParser,
	#superclass : #Object,
	#instVars : [
		'linuxVersion',
		'gtRr',
		'ipAddress'
	],
	#category : #'RemoteRunner-Syslog'
}

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

{ #category : #parsing }
GtRrSyslogParser >> parseFile: aFileReference [

	^ aFileReference readStreamDo: [ :stream |
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

	^ Array streamContents: [ :resultStream |
		[ stream atEnd ] whileFalse:
			 [ (self parseLine: stream nextLine) ifNotNil:
				[ :signal | resultStream nextPut: signal ] ] ].
]

{ #category : #'private ' }
GtRrSyslogParser >> signalFromLine: line index: index [ 

	^ GtRrSyslogSignal new
		basicTimestamp: (self timestampFrom: line);
		messageText: (line copyFrom: index to: line size);
		ipAddress: ipAddress.
]

{ #category : #'private - parsing' }
GtRrSyslogParser >> timestampFrom: line [ 
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
		[ dateAndTime year: today year - 1].
	^ dateAndTime.
]
