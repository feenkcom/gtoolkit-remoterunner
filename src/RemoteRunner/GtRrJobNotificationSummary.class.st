Class {
	#name : #GtRrJobNotificationSummary,
	#superclass : #GtNotificationSummary,
	#instVars : [
		'job',
		'notStartedLabel',
		'successfulLabel',
		'failedLabel'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #initialization }
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
		addChild: (notStartedLabel := BrLabel new
					aptitude: BrGlamorousLabelAptitude;
					beSmallSize;
					hFitContent;
					vExact: 15;
					margin: (BlInsets all: 3);
					layout: BlLinearLayout horizontal alignCenter;
					geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
					text: '0');
		addChild: (failedLabel := BrLabel new
					aptitude: BrGlamorousLabelAptitude;
					beSmallSize;
					hFitContent;
					vExact: 15;
					margin: (BlInsets all: 3);
					background: BrGlamorousColors errorBackgroundColor;
					layout: BlLinearLayout horizontal alignCenter;
					geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
					visibility: BlVisibility gone;
					text: '0');
		addChild: (successfulLabel := BrLabel new
					aptitude: BrGlamorousLabelAptitude;
					beSmallSize;
					hFitContent;
					vExact: 15;
					margin: (BlInsets all: 3);
					background: BrGlamorousColors successBackgroundColor;
					layout: BlLinearLayout horizontal alignCenter;
					geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
					visibility: BlVisibility gone;
					text: '0')
]

{ #category : #subscriptions }
GtRrJobNotificationSummary >> subscribeToNotifications [
	notifications do: [ :aNotification |
		aNotification
			when: GtNotificationDataChangedAnnouncement
			send: #requestUpdate
			to: self ]
]

{ #category : #subscriptions }
GtRrJobNotificationSummary >> unsubscribeFromNotifications [
	notifications do: [ :aNotification | 
		aNotification unsubscribe: self ]
]

{ #category : #updating }
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
	
	failedLabel text: failedCounter asString.
	successfulLabel text: successfulCounter asString.
	notStartedLabel text: notStartedCounter asString.
	
	failedLabel
		visibility: (failedCounter = 0 
			ifTrue: [ BlVisibility gone ] 
			ifFalse: [ BlVisibility visible ]).
	successfulLabel
		visibility: (successfulCounter = 0 
			ifTrue: [ BlVisibility gone ] 
			ifFalse: [ BlVisibility visible ]).
	notStartedLabel
		visibility: (notStartedCounter = 0 
			ifTrue: [ BlVisibility gone ] 
			ifFalse: [ BlVisibility visible ]).
]
