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
		^ {
			GtRrDataGroupState new
				name: 'All';
				color: Color transparent;
				items: self allTasks.
			GtRrDataGroupState new
				name: 'Success';
				color: Color lightGreen;
				items: aJob successfulExamples.
			GtRrDataGroupState new
				name: 'Skipped';
				color: Color veryVeryLightGray;
				items: aJob skippedExamples.
			GtRrDataGroupState new
				name: 'Failure';
				color: Color lightOrange;
				items: aJob failedExamples.
			GtRrDataGroupState new
				name: 'Error';
				color: Color red;
				items: aJob erroredExamples.
			GtRrDataGroupState new
				name: 'Not executed';
				color: Color veryVeryLightGray;
				items: self notExecutedTasks} ].
			
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
