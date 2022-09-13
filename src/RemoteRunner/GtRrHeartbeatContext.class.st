"
The heartbeat context is a little different from the others in that it checks all workers on each run and then reschedules itself.
"
Class {
	#name : #GtRrHeartbeatContext,
	#superclass : #GtRrContext,
	#instVars : [
		'remoteRunner',
		'nextRunTime'
	],
	#category : #'RemoteRunner-Runner-State'
}

{ #category : #'instance creation' }
GtRrHeartbeatContext class >> remoteRunner: aGtRemoteRunner [

	^ self new remoteRunner: aGtRemoteRunner
]

{ #category : #accessing }
GtRrHeartbeatContext >> contextTimeoutTime [
	"Answer the absolute time this context will time out"

	^ nextRunTime
]

{ #category : #initialization }
GtRrHeartbeatContext >> initialize [

	super initialize.
	"Add heartbeatDelay*2 since this is during system startup and there's no point checking early on"
	nextRunTime := DateAndTime now + (GtRrWorker heartbeatDelay * 2).
]

{ #category : #accessing }
GtRrHeartbeatContext >> isFinished [
	"The heartbeat context is finished when the remoteRunner stops"

	^ remoteRunner isRunning not
]

{ #category : #accessing }
GtRrHeartbeatContext >> remoteRunner [

	^ remoteRunner
]

{ #category : #accessing }
GtRrHeartbeatContext >> remoteRunner: anObject [

	remoteRunner := anObject
]

{ #category : #private }
GtRrHeartbeatContext >> scheduleTimeoutContext [
	"Same as above, but we don't want every poll logged"
	| future |

	future := [ self timeoutContext ] future.
	future onFailureDo: [ :anError |
		anError freeze.
		[ self error: anError printString ] fork ]

]

{ #category : #accessing }
GtRrHeartbeatContext >> timeoutContext [
	"Check all the worker heartbeats and stop any that have timed out"
	| now maxDuration registeredWorkers |

	"maxDuration needs to be large enough to allow for delivery delays"
	maxDuration := GtRrWorker heartbeatDelay * 1.5.
	registeredWorkers := remoteRunner critical:
		[ remoteRunner registeredWorkers ].
	now := DateAndTime now.
	registeredWorkers do: [ :workerContext |
		(now - workerContext lastHeartbeat) > maxDuration ifTrue:
			[ workerContext stopWithReason: 'Worker Heartbeat Lost' ] ].
	nextRunTime := DateAndTime now + GtRrWorker heartbeatDelay.
	remoteRunner timeoutManager addContext: self.
]
