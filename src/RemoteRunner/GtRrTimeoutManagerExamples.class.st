Class {
	#name : #GtRrTimeoutManagerExamples,
	#superclass : #Object,
	#traits : 'TAssertable + TGtRrExampleHelp',
	#classTraits : 'TAssertable classTrait + TGtRrExampleHelp classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrTimeoutManagerExamples >> getFinishedContexts [
	<gtExample>
	| timeoutManager timeout nextTimeout finishedContexts |

	timeoutManager := self newTimeoutManager.
	timeout := DateAndTime now + 1 day.
	nextTimeout := [ timeout := timeout + 1 second ].
	timeoutManager contexts
		add: (GtRrTestContext finished: true timeoutTime: nextTimeout value);
		add: (GtRrTestContext finished: false timeoutTime: nextTimeout value);
		add: (GtRrTestContext finished: true timeoutTime: nextTimeout value);
		add: (GtRrTestContext finished: false timeoutTime: nextTimeout value);
		add: (GtRrTestContext finished: true timeoutTime: nextTimeout value).
	finishedContexts := timeoutManager contextsForProcessing.
	self assert: finishedContexts isEmpty.
	self assert: timeoutManager contexts size equals: 2.
	self assert: (timeoutManager contexts noneSatisfy: [ :each | each isFinished ]).
]

{ #category : #examples }
GtRrTimeoutManagerExamples >> getTimedoutContexts [
	<gtExample>
	| timeoutManager future nextFuture past nextPast finishedContexts |

	timeoutManager := self newTimeoutManager.
	future := DateAndTime now + 1 day.
	nextFuture := [ future := future + 1 second ].
	past := DateAndTime now - 1 day.
	nextPast := [ past := past + 1 second ].
	timeoutManager contexts
		add: (GtRrTestContext finished: false timeoutTime: nextPast value);
		add: (GtRrTestContext finished: false timeoutTime: nextFuture value);
		add: (GtRrTestContext finished: false timeoutTime: nextPast value);
		add: (GtRrTestContext finished: false timeoutTime: nextFuture value);
		add: (GtRrTestContext finished: false timeoutTime: nextPast value).
	finishedContexts := timeoutManager contextsForProcessing.
	self assert: timeoutManager contexts size equals: 2.
	self assert: finishedContexts size equals: 3.
	self assert: (finishedContexts allSatisfy: [ :each | each contextTimeoutTime < DateAndTime now ]).
]

{ #category : #'private - accessing' }
GtRrTimeoutManagerExamples >> newTimeoutManager [
	"Answer a GtRrTimeoutManager that has enough state for the senders to run"

	^ GtRrTimeoutManager new
		remoteRunner: GtRemoteRunner new.
]
