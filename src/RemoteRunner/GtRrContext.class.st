Class {
	#name : #GtRrContext,
	#superclass : #Object,
	#category : #'RemoteRunner-Runner-State'
}

{ #category : #accessing }
GtRrContext >> contextTimeoutTime [
	"Answer the absolute time this context will time out"
	<return: #DateAndTime>

	^ self subclassResponsibility
]

{ #category : #testing }
GtRrContext >> isFinished [
	"Answer a boolean indicating whether the receiver has completed (with or without errors)"

	^ self subclassResponsibility
]

{ #category : #testing }
GtRrContext >> isJobContext [

	^ false
]

{ #category : #testing }
GtRrContext >> isPlatformContext [

	^ false
]

{ #category : #testing }
GtRrContext >> isTaskContext [

	^ false
]

{ #category : #accessing }
GtRrContext >> jobTimeout [

	^ self subclassResponsibility 
]

{ #category : #private }
GtRrContext >> scheduleTimeoutContext [
	| future |

	future := BlTktWorkerProvider nonUIMultiPool future:
		[ self timeoutContext ] asBlTktCommand.
	future onFailureDo: [ :anError |
		anError freeze.
		[ self error: anError printString ] fork ]

]

{ #category : #accessing }
GtRrContext >> taskTimeout [

	^ self subclassResponsibility 
]

{ #category : #private }
GtRrContext >> timeoutContext [
	"Terminate the receiver without timeout as the reason"

	self subclassResponsibility.
]
