"
The GtRrTimeoutManager is responsible for efficiently monitoring worker and job timeouts.

A single sorted collection of task and job contexts is maintained, sorted by absolute timeout time.  {{gtClass:BlTaskAtQueue}} is used to trigger a check when the next timeout could occur.


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
	| now context |

	remoteRunner isRunning ifFalse: [ ^ self ].
	contexts ifEmpty: [ ^ self ].
	now := DateAndTime now.
	[ contexts isNotEmpty and: 
		[ (context := contexts first) contextTimeoutTime <= now ] ] whileTrue:
			[ contexts removeFirst.
			context isFinished ifFalse:
				[ context scheduleTimeoutContext ] ].
	self updateScheduledTask.
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
	| future |

	remoteRunner isRunning ifFalse: [ ^ self ].
	future := [ self checkTimeouts ] future.
	future onFailureDo: [ :anError |
		anError freeze.
		[ self error: anError printString ] fork ]
]

{ #category : #accessing }
GtRrTimeoutManager >> size [
	"Answer the number of contexts being monitored"

	^ contexts size
]

{ #category : #private }
GtRrTimeoutManager >> updateScheduledTask [
	"Reschedule the scheduleTask so that it is executed at the appropriate time"

	contexts ifEmpty: [ ^ self ].
	nextTimeout := contexts first contextTimeoutTime.
	scheduleTask scheduledTime: nextTimeout.
	TaskAtQueue schedule: scheduleTask.

]
