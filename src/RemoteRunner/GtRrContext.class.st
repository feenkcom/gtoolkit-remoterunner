Class {
	#name : #GtRrContext,
	#superclass : #Object,
	#category : #'RemoteRunner-Runner-State'
}

{ #category : #'instance creation' }
GtRrContext class >> fromSton: stonReader [

	| signal |

	stonReader parseListDo: [ :each :idx |
		idx = 1 ifFalse: [ self error: 'Invalid STON' ].
		signal := self fromStonDictionary: each ].
	^signal
]

{ #category : #'instance creation' }
GtRrContext class >> fromStonDictionary: aDictionary [

	^ self new
]

{ #category : #'ston persistence' }
GtRrContext >> asDictionary [

	^ Dictionary new

]

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

{ #category : #'ston persistence' }
GtRrContext >> stonOn: stonWriter [

	stonWriter writeObject: self streamShortList: [ :array |
		array add: self asDictionary ]
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
