Extension { #name : #GtRrTask }

{ #category : #'*RemoteRunner' }
GtRrTask >> isRetry [
	"Answer a boolean indicating whether the receiver was created as a result of retrying a earlier task"

	^ retryStrategy isNotNil and:
	[ retryStrategy failedTask isNotNil ]
]

{ #category : #'*RemoteRunner' }
GtRrTask >> summaryAttributes [

	"Answer a collection of key/value attributes that can simply be listed as a summary of the receiver"

	| attributes duration |
	attributes := OrderedCollection new.
	duration := self duration.
	attributes add: #State -> self state.
	self hasErrors ifTrue: [ attributes add: #Error -> self errorDetails ].
	result ifNotNil: 
		[ attributes add: #Result -> (result isCollection
			ifTrue: [ result class name , '(' , result size printString , ')' ]
			ifFalse: [ result ]) ].
	self isRetry ifTrue:
		[ attributes add: #Retry -> (retryStrategy retryCount - 1) ].
	self startTime ifNotNil: [ attributes add: #Started -> self startTime ].
	self endTime ifNotNil: [ attributes add: #Ended -> self endTime ].
	duration ifNotNil: [ attributes add: #Duration -> duration ].
	self handoverTime ifNotNil: [ attributes add: #HandedToWorker -> self handoverTime ].
	(self handoverTime isNotNil and: [ self resultReceivedTime isNotNil ]) ifTrue: 
		[ attributes add: #ReceivedResultTime -> self resultReceivedTime ].
	self executionData resourceReport ifNotNil:
		[ :report | attributes add: #ResourceReport -> report ].
	taskTimeout ifNotNil: [ attributes add: #Timeout -> taskTimeout ].
	attributes add: #ID -> taskId.
	^ attributes
]
