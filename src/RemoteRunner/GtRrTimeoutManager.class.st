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

	contexts add: aGtRrContext.
	GtRrTimeoutManagerTrace new
		operation: #addContext;
		context: aGtRrContext;
		emit.
	self updateScheduledTask.
]

{ #category : #private }
GtRrTimeoutManager >> checkTimeouts [
	"Check the queue and timeout contexts as required"
	| now context |

	GtRrObjectTrace new
		object: contexts size;
		operation: #timeoutCheck;
		emit.
	contexts ifEmpty: [ ^ self ].
	remoteRunner sharedAccess critical:
		[ now := DateAndTime now.
		[ contexts isNotEmpty and: 
			[ (context := contexts first) contextTimeoutTime <= now ] ] whileTrue:
				[ contexts removeFirst.
				context isFinished ifFalse:
					[ GtRrContextTrace new
						context: context ;
						operation: #timeout;
						message: 'Initiating timeout termination';
						emit.
					context scheduleTimeoutContext.
					 ] ].
		self updateScheduledTask ].
]

{ #category : #initialization }
GtRrTimeoutManager >> initialize [

	super initialize.
	contexts := SortedCollection sortBlock: [ :a :b | a contextTimeoutTime < b contextTimeoutTime ].
	scheduleTask := BlTaskAtQueueTask
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

	future := BlTktWorkerProvider nonUIMultiPool future:
		[ self checkTimeouts ] asBlTktCommand.
	future onFailureDo: [ :anError |
		anError freeze.
		[ self error: anError printString ] fork ]
]

{ #category : #private }
GtRrTimeoutManager >> updateScheduledTask [
	"Reschedule the scheduleTask so that it is executed at the appropriate time"

	contexts ifEmpty: [ ^ self ].
	nextTimeout := contexts first contextTimeoutTime.
	nextTimeout < scheduleTask scheduledTime ifTrue:
		[ scheduleTask scheduledTime: nextTimeout.
		BlTaskAtQueue schedule: scheduleTask.
		GtRrTimeoutManagerTrace new
			operation: #schedule;
			message: nextTimeout printString;
			emit ].
]
