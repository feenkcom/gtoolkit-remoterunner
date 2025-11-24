Class {
	#name : #GtRrMqPromise,
	#superclass : #Object,
	#instVars : [
		'rpcId',
		'state',
		'semaphore',
		'successBlocks',
		'exceptionBlocks',
		'result',
		'sharedAccess',
		'stackString',
		'exceptionClassName',
		'messageText'
	],
	#category : 'RemoteRunner-MQ-Runner'
}

{ #category : #private }
GtRrMqPromise >> critical: aBlock [

	^ sharedAccess critical: aBlock
]

{ #category : #accessing }
GtRrMqPromise >> exception: anObject [
	self critical:
		[ result := anObject.
		state := #exception.
		exceptionBlocks do: [ :each |
			each value: result ].
		semaphore signalAll. ].
]

{ #category : #accessing }
GtRrMqPromise >> exceptionClassName [
	^exceptionClassName
]

{ #category : #accessing }
GtRrMqPromise >> exceptionClassName: anObject [
	exceptionClassName := anObject
]

{ #category : #initialization }
GtRrMqPromise >> initialize [

	super initialize.
	state := #unfulfilled.
	semaphore := Semaphore new.
	sharedAccess := Mutex new.
]

{ #category : #accessing }
GtRrMqPromise >> messageText [
	^messageText
]

{ #category : #accessing }
GtRrMqPromise >> messageText: anObject [
	messageText := anObject
]

{ #category : #accessing }
GtRrMqPromise >> processException [
	self critical:
		[ result := messageText.
		state := #exception.
		exceptionBlocks ifNotNil: [ exceptionBlocks do: [ :each |
			each cull: messageText cull: stackString cull: exceptionClassName ].
		semaphore signalAll. ] ].
]

{ #category : #accessing }
GtRrMqPromise >> result: anObject [
	self critical:
		[ result := anObject.
		state := #fulfilled.
		successBlocks ifNotNil:
			[ successBlocks do: [ :each |
				each value: result ] ].
		semaphore signalAll. ].
]

{ #category : #accessing }
GtRrMqPromise >> rpcId [
	^ rpcId
]

{ #category : #accessing }
GtRrMqPromise >> rpcId: anObject [
	rpcId := anObject
]

{ #category : #accessing }
GtRrMqPromise >> stackString [
	^ stackString
]

{ #category : #accessing }
GtRrMqPromise >> stackString: anObject [
	stackString := anObject
]

{ #category : #'as yet unclassified' }
GtRrMqPromise >> then: successBlock otherwise: failureBlock [

	self critical:
		[ state = #fulfilled ifTrue:
			[ ^ successBlock value: result ].
		state = #exception ifTrue:
			[ ^ failureBlock cull: messageText cull: stackString cull: exceptionClassName ].
		successBlocks add: successBlock.
		exceptionBlocks add: failureBlock ].
	
]

{ #category : #actions }
GtRrMqPromise >> wait [

	self critical:
		[ state = #unfulfilled ifFalse: [ ^ self ] ].
	semaphore wait.
]

{ #category : #actions }
GtRrMqPromise >> waitTimeoutMilliseconds: anInteger [

	self critical:
		[ state = #unfulfilled ifFalse: [ ^ self ] ].
	(semaphore waitTimeoutMilliseconds: anInteger) ifTrue:
		[ result := GtRrMqPromiseTimeout new timeout: anInteger.
		state := #exception ].
]

{ #category : #actions }
GtRrMqPromise >> waitTimeoutMSecs: anInteger [

	self critical:
		[ state = #unfulfilled ifFalse: [ ^ self ] ].
	(semaphore waitTimeoutMilliseconds: anInteger) ifTrue:
		[ result := GtRrMqPromiseTimeout new timeout: anInteger.
		state := #exception ].
]

{ #category : #actions }
GtRrMqPromise >> waitTimeoutSeconds: anInteger [

	self critical:
		[ state = #unfulfilled ifFalse: [ ^ self ] ].
	(semaphore waitTimeoutSeconds: anInteger) ifTrue:
		[ result := GtRrMqPromiseTimeout new timeout: anInteger.
		state := #exception ].
]
