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

	self
		addChild: (notStarted := BrLabel new
					aptitude: BrGlamorousLabelAptitude;
					exact: 15 @ 15;
					margin: (BlInsets all: 3);
					background: BrGlamorousColors neutralBackgroundColor;
					layout: BlLinearLayout horizontal alignCenter;
					geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
					text: '0');
		addChild: (failed := BrLabel new
					aptitude: BrGlamorousLabelAptitude;
					exact: 15 @ 15;
					margin: (BlInsets all: 3);
					background: BrGlamorousColors errorBackgroundColor;
					layout: BlLinearLayout horizontal alignCenter;
					geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
					text: '0');
		addChild: (successful := BrLabel new
					aptitude: BrGlamorousLabelAptitude;
					exact: 15 @ 15;
					margin: (BlInsets all: 3);
					background: BrGlamorousColors successBackgroundColor;
					layout: BlLinearLayout horizontal alignCenter;
					geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
					text: '0')
]

{ #category : #accessing }
GtRrJobNotificationSummary >> onNotificationsChanged [
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
			failedCounter := failedCounter + aNotification job resultsWithErrors size.
			aNotification job
				when: GtRrTaskAnnouncement
				send: #requestUpdate
				to: self ].
	failed text: failedCounter asString.
	successful text: successfulCounter asString.
	notStarted text: notStartedCounter asString
]
