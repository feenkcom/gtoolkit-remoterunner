Class {
	#name : #GtRrMsgPackLogEntry,
	#superclass : #Object,
	#instVars : [
		'line',
		'message',
		'time'
	],
	#category : 'RemoteRunner-Analysis'
}

{ #category : #accessing }
GtRrMsgPackLogEntry >> gtItemsFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Items';
		priority: 40;
		object: [ message ];
		view: #gtItemsFor:
]

{ #category : #testing }
GtRrMsgPackLogEntry >> isReceive [

	^ false
]

{ #category : #testing }
GtRrMsgPackLogEntry >> isSend [

	^ false
]

{ #category : #accessing }
GtRrMsgPackLogEntry >> line [
	^ line
]

{ #category : #accessing }
GtRrMsgPackLogEntry >> line: anObject [
	line := anObject
]

{ #category : #accessing }
GtRrMsgPackLogEntry >> message [
	^ message
]

{ #category : #accessing }
GtRrMsgPackLogEntry >> message: anObject [
	message := anObject
]

{ #category : #accessing }
GtRrMsgPackLogEntry >> time [
	^ time
]

{ #category : #accessing }
GtRrMsgPackLogEntry >> time: anObject [
	time := anObject
]
