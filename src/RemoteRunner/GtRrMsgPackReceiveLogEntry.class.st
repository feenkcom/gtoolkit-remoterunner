Class {
	#name : #GtRrMsgPackReceiveLogEntry,
	#superclass : #GtRrMsgPackLogEntry,
	#category : 'RemoteRunner-Analysis'
}

{ #category : #accessing }
GtRrMsgPackReceiveLogEntry >> bindings [
	| src bindings |

	src := message at: #bindings ifAbsent: [ ^ nil ].
	bindings := Dictionary new.
	src keysAndValuesDo: [ :key :value |
		bindings
			at: key
			put: (MpDecoder decode: value) ].
	^ bindings.
]

{ #category : #accessing }
GtRrMsgPackReceiveLogEntry >> commandId [

	^ message at: #commandId ifAbsent: []
]

{ #category : #accessing }
GtRrMsgPackReceiveLogEntry >> gtBindingsFor: aView [
	<gtView>
	
	self bindings ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Bindings';
		priority: 25;
		object: [ self bindings ];
		view: #gtLiveFor:
]

{ #category : #accessing }
GtRrMsgPackReceiveLogEntry >> gtStatementsFor: aView [
	<gtView>
	
	self statements ifNil: [ ^ aView empty ].
	^ aView text
		title: 'Statements';
		priority: 20;
		text: [ self statements ]
]

{ #category : #testing }
GtRrMsgPackReceiveLogEntry >> isReceive [

	^ true
]

{ #category : #printing }
GtRrMsgPackReceiveLogEntry >> printOn: aStream [

	message ifNil: [ ^ super printOn: aStream ].
	aStream
		<< 'recv id: ';
		<< self commandId asString.
]

{ #category : #accessing }
GtRrMsgPackReceiveLogEntry >> statements [

	^ message at: #statements ifAbsent: []
]
