Class {
	#name : #GtRrMsgPackSendLogEntry,
	#superclass : #GtRrMsgPackLogEntry,
	#category : 'RemoteRunner-Analysis'
}

{ #category : #accessing }
GtRrMsgPackSendLogEntry >> commandId [

	^ message at: #id ifAbsent: []
]

{ #category : #accessing }
GtRrMsgPackSendLogEntry >> gtPayloadValueFor: aView [
	<gtView>
	
	(message includesKey: #value) ifFalse:
		[ ^ aView empty ].
	^ aView forward
		title: 'Payload Value';
		priority: 30;
		object: [ self payloadValue ];
		view: #gtLiveFor:
]

{ #category : #testing }
GtRrMsgPackSendLogEntry >> isSend [

	^ true
]

{ #category : #accessing }
GtRrMsgPackSendLogEntry >> payloadSize [

	^ message
		at: #value
		ifPresent: #size
		ifAbsent: [ 0 ]
]

{ #category : #accessing }
GtRrMsgPackSendLogEntry >> payloadValue [

	^ MpDecoder new decode: (message at: #value)
]

{ #category : #accessing }
GtRrMsgPackSendLogEntry >> printOn: aStream [

	message ifNil: [ ^ super printOn: aStream ].
	aStream
		<< 'send id: ';
		<< self commandId asString.
]
