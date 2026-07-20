"
The GtRrTimeoutManager is responsible for efficiently monitoring worker and job timeouts.

A single sorted collection of task and job contexts is maintained, sorted by absolute timeout time.  {{gtClass:TaskAtQueue}} is used to trigger a check when the next timeout could occur.


"
Class {
	#name : #GtRrTimeoutManager,
	#superclass : #Object,
	#instVars : [
		'remoteRunner',
		'contexts',
		'nextTimeout',
		'scheduleTask'
	],
	#category : #'RemoteRunner-Runner-State'
}

{ #category : #'instance creation' }
GtRrTimeoutManager class >> remoteRunner: aGtRemoteRunner [

	^ self new remoteRunner: aGtRemoteRunner
]

{ #category : #adding }
GtRrTimeoutManager >> addContext: aGtRrContext [
	"Add the supplied context to the receiver's timeouts and update the check time if required.
	Must be called within the remoteRunner's sharedAccess"

	aGtRrContext contextTimeoutTime ifNil: [ ^ self ].
	contexts add: aGtRrContext.
	self updateScheduledTask.
]

{ #category : #private }
GtRrTimeoutManager >> checkTimeouts [
	"Check the queue and timeout contexts as required"
	| forProcessing |

	remoteRunner isRunning ifFalse: [ ^ self ].
	contexts ifEmpty: [ ^ self ].
	forProcessing := self contextsForProcessing.
	forProcessing do: [ :context |
			context scheduleTimeoutContext ].
	self updateScheduledTask.
]

{ #category : #'private - accessing' }
GtRrTimeoutManager >> contexts [

	^ contexts
]

{ #category : #private }
GtRrTimeoutManager >> contextsForProcessing [
	"Remove and answer the collection of contexts that have either:
	- expired, or
	- finished"
	| now index readyContexts |

	now := DateAndTime now.
	readyContexts := OrderedCollection new.
	remoteRunner critical: [
		"Iterate over the collection in reverse order
		as removing items near the end is cheaper."
		index := contexts size.
		[ index >= 1 ] whileTrue:
			[ | context |
			context := contexts at: index.
			context isFinished ifTrue:
				[ contexts removeAt: index ]
			ifFalse: [ context contextTimeoutTime <= now ifTrue:
				[ readyContexts add: context.
				contexts removeAt: index ] ].
			index := index - 1. ] ].
	^ readyContexts
]

{ #category : #ui }
GtRrTimeoutManager >> gtContextsFor: aView [
	<gtView>

	^ aView columnedList
		title: 'Contexts';
		priority: 10;
		items: [ contexts ];
		column: 'Context' text: [ :item | item ];
		column: 'Expires' text: [ :item | item contextTimeoutTime ];
		actionUpdateButton
]

{ #category : #initialization }
GtRrTimeoutManager >> initialize [

	super initialize.
	contexts := SortedCollection sortBlock: [ :a :b | a contextTimeoutTime < b contextTimeoutTime ].
	scheduleTask := TaskAtQueueTask
		valuable: [ self scheduleCheckTimeouts ]
		at: DateAndTime now + 1 hour
		entryIdentifier: Object new.
]

{ #category : #accessing }
GtRrTimeoutManager >> remoteRunner [

	^ remoteRunner
]

{ #category : #accessing }
GtRrTimeoutManager >> remoteRunner: anObject [

	remoteRunner := anObject
]

{ #category : #private }
GtRrTimeoutManager >> scheduleCheckTimeouts [
	"Schedule a timeout check to be run"
	| promise |

	remoteRunner isRunning ifFalse: [ ^ self ].
	promise := [ self checkTimeouts ] asAsyncForkedFuture 
		await: (AsyncFutureExecutionConfiguration new 
			lowPriority;
			customGroup: #RunnerTimeoutManager).
	promise 
		then: [ ]
		otherwise:  [ :anError |
			anError freeze.
			[ self error: anError printString ] fork ]
]

{ #category : #accessing }
GtRrTimeoutManager >> size [
	"Answer the number of contexts being monitored"

	^ contexts size
]

{ #category : #'start - stop' }
GtRrTimeoutManager >> stop [
	"Stop the receiver.
	The receiver will be automatically restarted if a context is added."
	
	TaskAtQueue default removeTask: scheduleTask
]

{ #category : #private }
GtRrTimeoutManager >> updateScheduledTask [
	"Reschedule the scheduleTask so that it is executed at the appropriate time"

	remoteRunner isRunning ifFalse: [ ^ self ].
	contexts ifEmpty: [ ^ self ].
	nextTimeout := contexts first contextTimeoutTime.
	scheduleTask scheduledTime: nextTimeout.
	TaskAtQueue schedule: scheduleTask.

]
