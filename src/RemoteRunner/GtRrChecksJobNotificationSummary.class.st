Class {
	#name : #GtRrChecksJobNotificationSummary,
	#superclass : #GtRrJobNotificationSummary,
	#category : #'RemoteRunner-Jobs-Notifications'
}

{ #category : #'building - widgets' }
GtRrChecksJobNotificationSummary >> createFailedLabel [
	^(BrLabel new)
		aptitude: BrGlamorousLabelAptitude;
		beSmallSize;
		hFitContent;
		vExact: 15;
		margin: (BlInsets all: 3);
		background: BrGlamorousColors failureBackgroundColor;
		layout: BlLinearLayout horizontal alignCenter;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
		visibility: BlVisibility gone;
		text: '0'
]

{ #category : #initialization }
GtRrChecksJobNotificationSummary >> initializeResultLabels [
	self
		addChild: (notStartedLabel := self createNotStartedLabel);
		addChild: (erroredLabel := self createErrorLabel);
		addChild: (failedLabel := self createFailedLabel);
		addChild: (successfulLabel := self createSuccessLabel)
]

{ #category : #updating }
GtRrChecksJobNotificationSummary >> updateSummaryContent [
	| successfulCounter notStartedCounter failedCounter erroredCounter |
	
	successfulCounter := 0.
	notStartedCounter := 0.
	failedCounter := 0.
	erroredCounter := 0.
	
	self notifications
		do: [ :aNotification | 
			successfulCounter := successfulCounter + aNotification successfulChecksCount.
			notStartedCounter := notStartedCounter 
				+ aNotification totalChecksCount
				- aNotification executedChecksCount.
			failedCounter := failedCounter 
				+ aNotification failedChecksCount.
			erroredCounter := erroredCounter 
				+ aNotification erroredChecksCount ].

	self updateLabel: erroredLabel withCount: erroredCounter.
	self updateLabel: failedLabel withCount: failedCounter.
	self updateLabel: successfulLabel withCount: successfulCounter.
	self updateLabel: notStartedLabel withCount: notStartedCounter.
]
