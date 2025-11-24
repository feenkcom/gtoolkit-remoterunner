Class {
	#name : #GtRrMqTaskProcessor,
	#superclass : #Object,
	#instVars : [
		'gtRrMqServer',
		'gtRrMqProcessor',
		'asyncWorkerConfiguration'
	],
	#category : 'RemoteRunner-MQ-Runner'
}

{ #category : #accessing }
GtRrMqTaskProcessor >> asyncWorkerConfiguration [

	^ asyncWorkerConfiguration ifNil:
		[ asyncWorkerConfiguration := AsyncFutureExecutionConfiguration new
			customGroup: self class name;
			maxAmountOfWorkers: 10;
			defaultPriority ].
]

{ #category : #accessing }
GtRrMqTaskProcessor >> gtRrMqProcessor [
	^gtRrMqProcessor
]

{ #category : #accessing }
GtRrMqTaskProcessor >> gtRrMqProcessor: aGtRrMqProcessor [

	gtRrMqProcessor := aGtRrMqProcessor.
	gtRrMqProcessor taskCallback: self taskCallback.
]

{ #category : #accessing }
GtRrMqTaskProcessor >> gtRrMqServer [
	^gtRrMqServer
]

{ #category : #accessing }
GtRrMqTaskProcessor >> gtRrMqServer: anObject [
	gtRrMqServer := anObject
]

{ #category : #private }
GtRrMqTaskProcessor >> taskCallback [
	"This replaces the default taskCallback and simply queues the callback to be run, ensuring that the StampClient isn't blocked"

	^ [ :mqMessage :gtMessage :anOwner |
		([ self gtRrMqProcessor processTaskMqMessage: mqMessage gtMessage: gtMessage owner: anOwner ] asAsyncFuture
			await: self asyncWorkerConfiguration)
				then: [ :v | ]
				otherwise: [ :ex |
					ex freeze.
					[ | theError |
					theError := ex.
					self error: 'Unexpected error while processing Mq message: ', theError messageText printString ] fork ].
		self gtRrMqProcessor write: mqMessage ackFrame. ].
]
