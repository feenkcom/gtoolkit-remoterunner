Class {
	#name : #GtRrJobNotificationSummary,
	#superclass : #GtNotificationSummary,
	#instVars : [
		'job',
		'notStartedLabel',
		'successfulLabel',
		'erroredLabel'
	],
	#category : #'RemoteRunner-Jobs-Notifications'
}

{ #category : #'building - widgets' }
GtRrJobNotificationSummary >> createErrorLabel [
	^(BrLabel new)
		aptitude: BrGlamorousLabelAptitude;
		beSmallSize;
		hFitContent;
		vExact: 15;
		margin: (BlInsets all: 3);
		background: BrGlamorousColors errorBackgroundColor;
		layout: BlLinearLayout horizontal alignCenter;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
		visibility: BlVisibility gone;
		text: '0'
]

{ #category : #'building - widgets' }
GtRrJobNotificationSummary >> createNotStartedLabel [
	^(BrLabel new)
		aptitude: BrGlamorousLabelAptitude;
		beSmallSize;
		hFitContent;
		vExact: 15;
		margin: (BlInsets all: 3);
		layout: BlLinearLayout horizontal alignCenter;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
		text: '0'
]

{ #category : #'building - widgets' }
GtRrJobNotificationSummary >> createSuccessLabel [
	^(BrLabel new)
		aptitude: BrGlamorousLabelAptitude;
		beSmallSize;
		hFitContent;
		vExact: 15;
		margin: (BlInsets all: 3);
		background: BrGlamorousColors successBackgroundColor;
		layout: BlLinearLayout horizontal alignCenter;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
		visibility: BlVisibility gone;
		text: '0'
]

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
	
	self initializeResultLabels
]

{ #category : #initialization }
GtRrJobNotificationSummary >> initializeResultLabels [
	self
		addChild: (notStartedLabel := self createNotStartedLabel);
		addChild: (erroredLabel := self createErrorLabel);
		addChild: (successfulLabel := self createSuccessLabel)
]

{ #category : #subscriptions }
GtRrJobNotificationSummary >> subscribeToNotifications [
	notifications do: [ :aNotification |
		aNotification weak
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
GtRrJobNotificationSummary >> updateLabel: aLabel withCount: anInteger [
	aLabel text: anInteger asString. 
	
	aLabel
		visibility: (anInteger = 0 
			ifTrue: [ BlVisibility gone ] 
			ifFalse: [ BlVisibility visible ]).
]

{ #category : #updating }
GtRrJobNotificationSummary >> updateSummaryContent [
	| successfulCounter notStartedCounter failedCounter |
	
	successfulCounter := 0.
	notStartedCounter := 0.
	failedCounter := 0.
	
	self notifications
		do: [ :aNotification | 
			successfulCounter := successfulCounter + aNotification succeededCount.
			notStartedCounter := notStartedCounter
					+ (aNotification taskCount - aNotification succeededCount - aNotification erroredCount).
			failedCounter := failedCounter + aNotification erroredCount ].
	
	self updateLabel: erroredLabel withCount: failedCounter.
	self updateLabel: successfulLabel withCount: successfulCounter.
	self updateLabel: notStartedLabel withCount: notStartedCounter.
]
