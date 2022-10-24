Class {
	#name : #GtRrFutureTimeoutableTaskExecution,
	#superclass : #TKTFutureExecution,
	#instVars : [
		'timeout'
	],
	#category : #'RemoteRunner-Runner-State'
}

{ #category : #evaluating }
GtRrFutureTimeoutableTaskExecution >> doExecuteTask [

	timeout ifNotNil:
		[ TKTConfiguration runner scheduleTimeout: timeout on: self ].
	^ super doExecuteTask.
]

{ #category : #accessing }
GtRrFutureTimeoutableTaskExecution >> task [

	^ task
]

{ #category : #accessing }
GtRrFutureTimeoutableTaskExecution >> timeout [

	^ timeout
]

{ #category : #accessing }
GtRrFutureTimeoutableTaskExecution >> timeout: aDuration [

	timeout := aDuration
]
