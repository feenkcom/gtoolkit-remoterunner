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
	^ job allExamples
	"^ job tasks flatCollect: #allMethods"
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
			elements: job successfulExamples.
		GtRrExamplesStateElement
			name: 'Skipped'
			color: Color veryVeryLightGray
			elements: job skippedExamples.
		GtRrExamplesStateElement
			name: 'Failure'
			color: Color lightOrange
			elements: job failedExamples.
		GtRrExamplesStateElement
			name: 'Error'
			color: Color red
			elements: job erroredExamples.
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
	^ job notExecutedExamples
]

{ #category : #'private - hooks' }
GtRrExamplesNotificationElement >> onTaskAnnouncement: aGtRrTaskAnnouncement [

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
