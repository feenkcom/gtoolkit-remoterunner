Class {
	#name : #GtRrJobNotificationSummary,
	#superclass : #GtNotificationSummary,
	#instVars : [
		'notStarted',
		'job',
		'failed',
		'successful'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #accessing }
GtRrJobNotificationSummary >> initialize [
	super initialize.
	
	self
		constraintsDo: [ :c | 
			c vertical exact: 21.
			c horizontal fitContent ].
	self layout: BlLinearLayout horizontal.
	self border: (BlBorder paint: Color orange width: 2).
	self geometry: (BlRoundedRectangleGeometry cornerRadius: 4).
	self padding: (BlInsets left: 5 right: 5).
	self background: Color white.
	
	self
		addChild: (notStarted := BrLabel new
					aptitude: BrGlamorousLabelAptitude;
					beSmallSize;
					exact: 15 @ 15;
					margin: (BlInsets all: 3);
					layout: BlLinearLayout horizontal alignCenter;
					geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
					text: '0');
		addChild: (failed := BrLabel new
					aptitude: BrGlamorousLabelAptitude;
					beSmallSize;
					exact: 15 @ 15;
					margin: (BlInsets all: 3);
					background: BrGlamorousColors errorBackgroundColor;
					layout: BlLinearLayout horizontal alignCenter;
					geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
					visibility: BlVisibility gone;
					text: '0');
		addChild: (successful := BrLabel new
					aptitude: BrGlamorousLabelAptitude;
					beSmallSize;
					exact: 15 @ 15;
					margin: (BlInsets all: 3);
					background: BrGlamorousColors successBackgroundColor;
					layout: BlLinearLayout horizontal alignCenter;
					geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
					visibility: BlVisibility gone;
					text: '0')
]

{ #category : #accessing }
GtRrJobNotificationSummary >> subscribeToNotifications [
	notifications do: [ :aNotification |
		aNotification job
			when: GtRrTaskAnnouncement
			send: #requestUpdate
			to: self ]
]

{ #category : #accessing }
GtRrJobNotificationSummary >> unsubscribeFromNotifications [
	notifications do: [ :aNotification | 
		aNotification job unsubscribe: self ]
]

{ #category : #accessing }
GtRrJobNotificationSummary >> updateSummaryContent [
	| successfulCounter notStartedCounter failedCounter |
	
	successfulCounter := 0.
	notStartedCounter := 0.
	failedCounter := 0.
	
	self notifications
		do: [ :aNotification | 
			successfulCounter := successfulCounter
					+ (aNotification job results reject: #hasErrors) size.
			notStartedCounter := notStartedCounter
					+ (aNotification job tasks reject: #isFinished) size.
			failedCounter := failedCounter + aNotification job resultsWithErrors size ].
	
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
