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
		'stackString'
	],
	#category : #'RemoteRunner-MQ-Runner'
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

{ #category : #initialization }
GtRrMqPromise >> initialize [

	super initialize.
	state := #unfulfilled.
	semaphore := Semaphore new.
	sharedAccess := Mutex new.
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
			[ ^ failureBlock value: result ].
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
GtRrMqPromise >> waitTimeoutMSecs: anInteger [

	self critical:
		[ state = #unfulfilled ifFalse: [ ^ self ] ].
	(semaphore waitTimeoutMSecs: anInteger) ifTrue:
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
