"
GtRrJobNotificationElement is the element displayed in the list of notifications for a running job.

Main attributes of the notification:

- It is displayed until explicitly dismissed by the user.
- The task execution state is automatically updated.
- The job can be inspected by the user.
"
Class {
	#name : #GtRrJobNotificationElement,
	#superclass : #GtNotificationEventElement,
	#instVars : [
		'nameLabel',
		'borderElement',
		'job',
		'successfulLabel',
		'erroredLabel',
		'progressElement',
		'infoButton',
		'runAgainButton',
		'remainingLabel'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #'private - accessing' }
GtRrJobNotificationElement >> borderElement [
	<return: #GtNotificationBorderElement>
	^ borderElement
]

{ #category : #initialization }
GtRrJobNotificationElement >> defaultLayout [
	^ BlLinearLayout vertical alignCenterRight
]

{ #category : #'private - accessing' }
GtRrJobNotificationElement >> errorCount [

	^ job errorCount
]

{ #category : #initialization }
GtRrJobNotificationElement >> initialize [
	| namePane statePane |

	super initialize.
	self initializeBorderElement.
	namePane := self initializeNameLabel.
	statePane := self initializeStateElement.
	self initializeProgressElement.
	
	self addChild: self borderElement as: #border.
	self borderElement containerDo: [ :aContainer |
		aContainer 
			addChild: namePane;
			addChild: statePane;
			addChild: progressElement as: #progressElement ].
	
	self addAptitude: (BrLayoutResizerAptitude new
		hInherit;
		vAnyToFitContent;
		hInherit: self borderElement;
		vAnyToFitContent: self borderElement;
		hInherit: statePane;
		vAnyToFitContent: statePane).
]

{ #category : #initialization }
GtRrJobNotificationElement >> initializeBorderElement [
	borderElement := GtNotificationBorderElement new
		withCloseButtonAction: [ self dismiss ]
]

{ #category : #initialization }
GtRrJobNotificationElement >> initializeNameLabel [
	| horizontalPane |

	horizontalPane := BrHorizontalPane new
			margin: (BlInsets bottom: 3);
			hMatchParent;
			vFitContent.
	nameLabel := BrLabel new
			aptitude: BrGlamorousLabelAptitude;
			fitContent.
	infoButton := BrButton new
			beTinySize;
			aptitude: BrGlamorousButtonWithIconAptitude;
			label: 'Inspect Job';
			icon: BrGlamorousVectorIcons inspect;
			margin: (BlInsets top: 2 left: 10);
			action: [ self inspectJob ].
	runAgainButton := BrButton new
			beTinySize;
			aptitude: BrGlamorousButtonWithIconAptitude;
			label: 'Run Job Again';
			icon: BrGlamorousVectorIcons play;
			margin: (BlInsets top: 2 left: 10);
			action: [ self runJobAgain ].
	horizontalPane
		addChild: nameLabel;
		addChild: infoButton;
		addChild: runAgainButton.
	^ horizontalPane
]

{ #category : #initialization }
GtRrJobNotificationElement >> initializeProgressElement [

	progressElement := BrProgress new
		fixedLabel: '';
		aptitude: BrGlamorousProgressWithBarAptitude;
		layoutDo: [ :aLayout | 
			aLayout alignCenterLeft ]
]

{ #category : #initialization }
GtRrJobNotificationElement >> initializeStateElement [
	| horizontalPane remainingBackground successfulBackground erroredBackground |

	horizontalPane := BrHorizontalPane new
		margin: (BlInsets bottom: 5);
		hMatchParent;
		vFitContent.
	remainingLabel := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
			padding: (BlInsets left: 3 right: 3);
			foreground: Color black);
		text: ''.
	remainingBackground := BlElement new
		background: Color lightGray;
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent. ];
		addChild: remainingLabel.
	successfulLabel := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
			padding: (BlInsets left: 3 right: 3);
			foreground: Color black);
		text: ''.
	successfulBackground := BlElement new
		background: Color lightGreen;
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent. ];
		addChild: successfulLabel.
	erroredLabel := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
			padding: (BlInsets left: 3 right: 3);
			foreground: Color white);
		text: ''.
	erroredBackground := BlElement new
		background: Color red;
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent. ];
		addChild: erroredLabel.
	horizontalPane 
		addChild: remainingBackground;
		addChild: (BrLabel new 
			aptitude: BrGlamorousLabelAptitude new;
			margin: (BlInsets left: 3 right: 3);
			text: 'remaining');
		addChild: successfulBackground;
		addChild: (BrLabel new 
			aptitude: BrGlamorousLabelAptitude new;
			margin: (BlInsets left: 3 right: 3);
			text: 'successful');
		addChild: erroredBackground;
		addChild: (BrLabel new 
			aptitude: BrGlamorousLabelAptitude new;
			margin: (BlInsets left: 3 right: 3);
			text: 'errored').
	^ horizontalPane
]

{ #category : #private }
GtRrJobNotificationElement >> inspectJob [
	"Inspect the receiver's job in a new tab in GtWorld"

	GtInspectorTool
		openWrappedOn: job
		title: job name
		from: self

]

{ #category : #'api - accessing' }
GtRrJobNotificationElement >> message [

	job ifNil: [ ^ '<no job>' ].
	^ String streamContents: [ :stream |
		stream
			<< 'Remain: ';
			print: (job taskCount - job successfulCount - job errorCount);
			<< ', Done: ';
			print: job successfulCount;
			<< ', Failed: ';
			print: job errorCount ]
]

{ #category : #'private - accessing' }
GtRrJobNotificationElement >> name [

	^ job name
]

{ #category : #'api - accessing' }
GtRrJobNotificationElement >> notification: aGtRrJobNotification [

	job := aGtRrJobNotification job.
	super notification: aGtRrJobNotification.
	self updateDisplay.
]

{ #category : #'private - hooks' }
GtRrJobNotificationElement >> onTaskAnnouncement: aGtRrTaskAnnouncement [

	aGtRrTaskAnnouncement class = GtRrTaskStartedAnnouncement ifTrue: [ ^ self ].

	self updateDisplay.
]

{ #category : #'private - accessing' }
GtRrJobNotificationElement >> progress [

	^ (self successfulCount + self errorCount) / self totalCount
]

{ #category : #private }
GtRrJobNotificationElement >> runJobAgain [
	"Create a copy of the receiver's job and run it with progress notifications"
	| jobCopy |

	jobCopy := job copy.
	jobCopy showProgressNotification.
	GtRemoteRunner default submitJob: jobCopy.
]

{ #category : #'private - subscriptions' }
GtRrJobNotificationElement >> subscribeToNotification [

	job
		when: GtRrTaskAnnouncement
			send: #onTaskAnnouncement: to: self.
]

{ #category : #'private - accessing' }
GtRrJobNotificationElement >> successfulCount [

	^ job successfulCount
]

{ #category : #'private - accessing' }
GtRrJobNotificationElement >> totalCount [

	^ job taskCount
]

{ #category : #'private - subscriptions' }
GtRrJobNotificationElement >> unsubscribeFromNotification [

	job unsubscribe: self.
]

{ #category : #'private - updating' }
GtRrJobNotificationElement >> updateDisplay [

	self enqueueTask: (BlTaskAction new action:
		[ nameLabel text: self name.
		remainingLabel text: (self totalCount - self successfulCount - self errorCount) asString.
		successfulLabel text: self successfulCount asString.
		erroredLabel text: self errorCount asString.
		progressElement fraction: self progress ]).
]
