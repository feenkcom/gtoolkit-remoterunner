Class {
	#name : #GtRrMsgPackLogAnalyser,
	#superclass : #Object,
	#instVars : [
		'file',
		'entries',
		'paired'
	],
	#category : #'RemoteRunner-Analysis'
}

{ #category : #accessing }
GtRrMsgPackLogAnalyser >> file [
	^ file
]

{ #category : #accessing }
GtRrMsgPackLogAnalyser >> file: aFileReference [

	file := aFileReference.
	self load.
]

{ #category : #private }
GtRrMsgPackLogAnalyser >> load [
	| lf |

	lf := Character lf asciiValue.
	entries := OrderedCollection new.
	file asFileReference binaryReadStreamDo: [ :stream |
		[ stream atEnd ] whileFalse:
			[ self processLine: (stream upTo: lf) asString] ]
]

{ #category : #accessing }
GtRrMsgPackLogAnalyser >> paired [
	"Answer pairs of entries based on command Id"
	| unmatched index1 index2 entry found |

	paired ifNotNil: [ ^ paired ].
	unmatched := entries copy.
	paired := Dictionary new.
	index1 := 1.
	[ index1 <= unmatched size ] whileTrue:
		[ entry := unmatched at: index1.
		index2 := index1 + 1.
		found := false.
		[ index2 < unmatched size and: [ found not ] ] whileTrue:
			[ entry commandId = (unmatched at: index2) commandId ifTrue:
				[ found := true ]
			ifFalse:
				[ index2 := index2 + 1 ] ].
		found ifTrue:
			[ paired at: (unmatched at: index1) commandId
				put: (unmatched at: index1) -> (unmatched at: index2).
			unmatched removeAtIndex: index2.
			unmatched removeAtIndex: index1 ]
		ifFalse:
			[ index1 := index1 + 1 ] ].

	^ paired.
]

{ #category : #private }
GtRrMsgPackLogAnalyser >> processLine: aString [

	(aString beginsWith: 'msgPackNext:') ifTrue:
		[ self processMsgPackNextLine: aString ].
	(aString beginsWith: 'msgPackSend:') ifTrue:
		[ self processMsgPackSendLine: aString ].
]

{ #category : #private }
GtRrMsgPackLogAnalyser >> processMsgPackNextLine: aString [
	| fields time entry |

	fields := aString splitOn: Character space.
	time := Time readFromString: fields second.
	entry := GtRrMsgPackReceiveLogEntry new
		line: aString;
		time: time;
		message: (MpDecoder decode:
			fields fourth base64Decoded).
	entries add: entry.
]

{ #category : #private }
GtRrMsgPackLogAnalyser >> processMsgPackSendLine: aString [
	| fields time entry |

	fields := aString splitOn: Character space.
	time := Time readFromString: fields second.
	entry := GtRrMsgPackSendLogEntry new
		line: aString;
		time: time;
		message: (MpDecoder decode:
			fields fourth base64Decoded).
	entries add: entry.
]

{ #category : #accessing }
GtRrMsgPackLogAnalyser >> sendWithoutReceive [
	"Answer a collection of messages that are sent but have no matching response"
	| unmatched index1 index2 entry found |

	unmatched := entries copy.
	index1 := 1.
	[ index1 <= unmatched size ] whileTrue:
		[ entry := unmatched at: index1.
		index2 := index1 + 1.
		found := false.
		[ index2 < unmatched size and: [ found not ] ] whileTrue:
			[ entry commandId = (unmatched at: index2) commandId ifTrue:
				[ found := true ]
			ifFalse:
				[ index2 := index2 + 1 ] ].
		found ifTrue:
			[ unmatched removeAtIndex: index2.
			unmatched removeAtIndex: index1 ]
		ifFalse:
			[ index1 := index1 + 1 ] ].
	^ unmatched.
]
