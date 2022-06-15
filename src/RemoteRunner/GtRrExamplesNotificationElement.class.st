"
GtRrExamplesNotificationElement provides similar notifications to its superclass ({{gtClass:GtRrJobNotificationElement}}), but counts individual examples / tests instead of tasks (each task can run one or more examples / tests).
"
Class {
	#name : #GtRrExamplesNotificationElement,
	#superclass : #GtRrJobNotificationElement,
	#instVars : [
		'successful',
		'errored',
		'failed',
		'skipped'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #accessing }
GtRrExamplesNotificationElement >> allTasks [
	^ job tasks flatCollect: #allMethods
]

{ #category : #accessing }
GtRrExamplesNotificationElement >> constructStates [
	job ifNil: [ ^ {} ].
	^ {GtRrExamplesStateElement
			name: 'All'
			color: Color transparent
			elements: self allTasks.
		GtRrExamplesStateElement
			name: 'Success'
			color: Color lightGreen
			elements: (job tasks flatCollect: [:aTask | aTask successfulExamples collect: #method]).
		GtRrExamplesStateElement
			name: 'Skipped'
			color: Color veryVeryLightGray
			elements: (job tasks flatCollect: [:aTask | aTask skippedExamples collect: #method]).
		GtRrExamplesStateElement
			name: 'Failure'
			color: Color lightOrange
			elements: (job tasks flatCollect: [:aTask | aTask failedExamples collect: #method]).
		GtRrExamplesStateElement
			name: 'Error'
			color: Color red
			elements: (job tasks flatCollect: [:aTask | aTask erroredExamples collect: #method]).
		GtRrExamplesStateElement
			name: 'Not executed'
			color: Color veryVeryLightGray
			elements: self notExecutedTasks}
]

{ #category : #accessing }
GtRrExamplesNotificationElement >> name [

	^ job name
]

{ #category : #accessing }
GtRrExamplesNotificationElement >> notExecutedTasks [
	^ (job tasks reject: #isFinished) flatCollect: #allMethods
]

{ #category : #'private - hooks' }
GtRrExamplesNotificationElement >> onTaskAnnouncement: aGtRrTaskAnnouncement [
	| task |

	aGtRrTaskAnnouncement class = GtRrTaskStartedAnnouncement ifTrue: [ ^ self ].
	
	self updateDisplay.
]

{ #category : #private }
GtRrExamplesNotificationElement >> runJobAgain [
	"Create a copy of the receiver's job and run it with progress notifications"
	| jobCopy |

	jobCopy := job copy.
	jobCopy showExamplesProgressNotification.
	GtRemoteRunner default submitJob: jobCopy.
]

{ #category : #'private - subscriptions' }
GtRrExamplesNotificationElement >> subscribeToNotification [

	job := notification job.
	successful := OrderedCollection new.
	errored := OrderedCollection new.
	failed := OrderedCollection new.
	skipped := OrderedCollection new.
	super subscribeToNotification.

]
