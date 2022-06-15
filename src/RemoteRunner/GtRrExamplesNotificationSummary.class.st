Class {
	#name : #GtRrExamplesNotificationSummary,
	#superclass : #GtRrJobNotificationSummary,
	#category : #'RemoteRunner-UI'
}

{ #category : #accessing }
GtRrExamplesNotificationSummary >> onNotificationsChanged [
	| successfulCounter notStartedCounter failedCounter |
	successfulCounter := 0.
	notStartedCounter := 0.
	failedCounter := 0.
	self notifications
		do: [ :aNotification | 
			| tasks |
			tasks := aNotification job tasks.
			successfulCounter := successfulCounter
					+ (tasks flatCollect: #successfulExamples) size.
			notStartedCounter := notStartedCounter + (tasks collect: #totalCount) sum
					- (tasks flatCollect: #executedExamples) size.
			failedCounter := failedCounter + (tasks flatCollect: #failedExamples) size
					+ (tasks flatCollect: #erroredExamples) size.
			aNotification job
				when: GtRrTaskAnnouncement
				send: #requestUpdate
				to: self ].
	failed text: failedCounter asString.
	successful text: successfulCounter asString.
	notStarted text: notStartedCounter asString.
	failed
		visibility: (failedCounter = 0 ifTrue: [ BlVisibility gone ] ifFalse: [ BlVisibility visible ]).
	successful
		visibility: (successfulCounter = 0 ifTrue: [ BlVisibility gone ] ifFalse: [ BlVisibility visible ]).
	notStarted
		visibility: (notStartedCounter = 0 ifTrue: [ BlVisibility gone ] ifFalse: [ BlVisibility visible ]).
]
