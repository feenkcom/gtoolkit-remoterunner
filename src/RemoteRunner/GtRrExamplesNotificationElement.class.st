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
	^ self currentJob allExamples
	"^ self currentJob tasks flatCollect: #allMethods"
]

{ #category : #accessing }
GtRrExamplesNotificationElement >> constructStates [
	self jobDo: [ :aJob |
		^ {GtRrExamplesStateElement
			name: 'All'
			color: Color transparent
			elements: self allTasks.
		GtRrExamplesStateElement
			name: 'Success'
			color: Color lightGreen
			elements: aJob successfulExamples.
		GtRrExamplesStateElement
			name: 'Skipped'
			color: Color veryVeryLightGray
			elements: aJob skippedExamples.
		GtRrExamplesStateElement
			name: 'Failure'
			color: Color lightOrange
			elements: aJob failedExamples.
		GtRrExamplesStateElement
			name: 'Error'
			color: Color red
			elements: aJob erroredExamples.
		GtRrExamplesStateElement
			name: 'Not executed'
			color: Color veryVeryLightGray
			elements: self notExecutedTasks} ].
			
	^ #()
]

{ #category : #accessing }
GtRrExamplesNotificationElement >> name [

	^ 'Run Examples (', self currentJob  state, ')'
]

{ #category : #accessing }
GtRrExamplesNotificationElement >> notExecutedTasks [
	^ self currentJob notExecutedExamples
]

{ #category : #'private - hooks' }
GtRrExamplesNotificationElement >> onTaskAnnouncement: aGtRrTaskAnnouncement [

	aGtRrTaskAnnouncement class = GtRrTaskStartedAnnouncement ifTrue: [ ^ self ].
	
	self requestUpdate.
]

{ #category : #private }
GtRrExamplesNotificationElement >> runJobAgain [
	"Create a copy of the receiver's job and run it with progress notifications"
	| jobCopy |

	jobCopy := self currentJob copy.
	jobCopy showExamplesProgressNotification.
	
	GtRemoteRunner default submitJob: jobCopy.
]

{ #category : #'private - subscriptions' }
GtRrExamplesNotificationElement >> subscribeToNotification [
	
	successful := OrderedCollection new.
	errored := OrderedCollection new.
	failed := OrderedCollection new.
	skipped := OrderedCollection new.
	super subscribeToNotification.

]
