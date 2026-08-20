Class {
	#name : #GtRrTallyingTask,
	#superclass : #GtRrTask,
	#instVars : [
		'innerTask'
	],
	#category : #'RemoteRunner-Tests'
}

{ #category : #accessing }
GtRrTallyingTask >> innerTask [
	^ innerTask
]

{ #category : #accessing }
GtRrTallyingTask >> innerTask: anObject [
	innerTask := anObject
]

{ #category : #'as yet unclassified' }
GtRrTallyingTask >> run [
	| messageTally innerResult |

	messageTally := MessageTally new.
	messageTally reportOtherProcesses: true.
	messageTally 
		spyAllEvery: MessageTally defaultPollPeriod
		on: [ innerResult := innerTask run ].
	self executionData additionalData
		at: #messageTally
		put: (String streamContents: [ :stream |
			messageTally report: stream cutoff: 5 ]).
	^ innerResult
]
