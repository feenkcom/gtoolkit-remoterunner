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
GtRrExamplesNotificationElement >> constructStates [
	job ifNil: [ ^ {} ].
	^ {GtRrExamplesStateElement
			name: 'All'
			color: Color transparent
			elements: (job tasks flatCollect: #allMethods).
		GtRrExamplesStateElement
			name: 'Success'
			color: Color lightGreen
			elements: successful.
		GtRrExamplesStateElement
			name: 'Skipped'
			color: Color veryVeryLightGray
			elements: skipped.
		GtRrExamplesStateElement
			name: 'Failure'
			color: Color lightOrange
			elements: failed.
		GtRrExamplesStateElement
			name: 'Error'
			color: Color red
			elements: errored.
		GtRrExamplesStateElement
			name: 'Not executed'
			color: Color veryVeryLightGray
			elements: ((job tasks reject: #isFinished) flatCollect: #allMethods)}
]

{ #category : #accessing }
GtRrExamplesNotificationElement >> name [

	^ job name
]

{ #category : #'private - hooks' }
GtRrExamplesNotificationElement >> onTaskAnnouncement: aGtRrTaskAnnouncement [
	| task |

	aGtRrTaskAnnouncement class = GtRrTaskStartedAnnouncement ifTrue: [ ^ self ].

	task := aGtRrTaskAnnouncement task.
	successful addAll: (task successfulExamples collect: #method).
	errored addAll: (task erroredExamples collect: #method).
	failed addAll: (task failedExamples collect: #method).
	skipped addAll: (task skippedExamples collect: #method).
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
