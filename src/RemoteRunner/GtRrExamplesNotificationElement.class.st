"
GtRrExamplesNotificationElement provides similar notifications to its superclass ({{gtClass:GtRrJobNotificationElement}}), but counts individual examples / tests instead of tasks (each task can run one or more examples / tests).
"
Class {
	#name : #GtRrExamplesNotificationElement,
	#superclass : #GtRrJobNotificationElement,
	#instVars : [
		'totalCount',
		'successfulCount',
		'errorCount'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #accessing }
GtRrExamplesNotificationElement >> errorCount [

	^ errorCount
]

{ #category : #private }
GtRrExamplesNotificationElement >> getTotalCount [

	^ job tasks inject: 0 into: [ :s :v | s + v totalCount ]
]

{ #category : #accessing }
GtRrExamplesNotificationElement >> name [

	^ totalCount asString, ' tests'.

]

{ #category : #'private - hooks' }
GtRrExamplesNotificationElement >> onTaskAnnouncement: aGtRrTaskAnnouncement [
	| task |

	aGtRrTaskAnnouncement class = GtRrTaskStartedAnnouncement ifTrue: [ ^ self ].

	task := aGtRrTaskAnnouncement task.
	successfulCount := successfulCount + task successfulExamples size.
	errorCount := errorCount + task erroredExamples size + task failedExamples size.
	self updateDisplay.
]

{ #category : #'private - subscriptions' }
GtRrExamplesNotificationElement >> subscribeToNotification [

	successfulCount := errorCount := 0.
	totalCount := self getTotalCount.
	super subscribeToNotification.

]

{ #category : #accessing }
GtRrExamplesNotificationElement >> successfulCount [

	^ successfulCount
]

{ #category : #accessing }
GtRrExamplesNotificationElement >> totalCount [

	^ totalCount
]
