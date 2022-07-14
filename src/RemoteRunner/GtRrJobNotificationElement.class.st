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
		'infoButton',
		'runAgainButton',
		'statePane',
		'isFinished'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #accessing }
GtRrJobNotificationElement >> allTasks [
	^ job tasks
]

{ #category : #'private - accessing' }
GtRrJobNotificationElement >> borderElement [
	<return: #GtNotificationBorderElement>
	^ borderElement
]

{ #category : #accessing }
GtRrJobNotificationElement >> constructStates [
	job ifNil: [ ^ {} ].
	
	^ {GtRrStateElement
			name: 'All'
			color: Color transparent
			elements: self allTasks.
		GtRrStateElement
			name: 'Success'
			color: Color lightGreen
			elements: (job results reject: #hasErrors).
		GtRrStateElement
			name: 'Failure'
			color: Color red
			elements: job resultsWithErrors.
		GtRrStateElement
			name: 'Not executed'
			color: Color veryVeryLightGray
			elements: self notExecutedTasks}
]

{ #category : #initialization }
GtRrJobNotificationElement >> defaultLayout [
	^ BlLinearLayout vertical alignCenterRight
]

{ #category : #initialization }
GtRrJobNotificationElement >> initialize [
	| namePane toolbarPane |

	super initialize.

	isFinished := false.
	
	self initializeBorderElement.
	namePane := self initializeNameLabel.
	statePane := self initializeStateElement.
	toolbarPane := self initializeToolbar.
	
	self addChild: self borderElement as: #border.
	self borderElement containerDo: [ :aContainer |
		aContainer 
			addChild: namePane;
			addChild: statePane;
			addChild: toolbarPane ].
	
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
			aptitude: (BrGlamorousLabelAptitude new 
				foreground: BrGlamorousColors disabledHeaderTextColor);
			fitContent.
	horizontalPane
		addChild: (BlElement new size: 10@10);
		addChild: nameLabel.
	^ horizontalPane
]

{ #category : #initialization }
GtRrJobNotificationElement >> initializeStateElement [
	| verticalPane states |

	verticalPane := BrVerticalPane new
		margin: (BlInsets bottom: 5);
		hMatchParent;
		vFitContent.
	states := self constructStates.
	
	states do: [:state | verticalPane addChild: state ].
	
	^ verticalPane
]

{ #category : #initialization }
GtRrJobNotificationElement >> initializeToolbar [
	| horizontalPane |
	horizontalPane := BrHorizontalPane new
			hMatchParent;
			vFitContent;
			alignCenterRight.
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
		addChild: infoButton;
		addChild: runAgainButton.
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

{ #category : #accessing }
GtRrJobNotificationElement >> notExecutedTasks [
	^ job tasks reject: #isFinished
]

{ #category : #accessing }
GtRrJobNotificationElement >> onAddedToSceneGraph [
	self updateDisplay
]

{ #category : #'private - hooks' }
GtRrJobNotificationElement >> onNotificationChanged [

	self updateDisplay.
]

{ #category : #'private - hooks' }
GtRrJobNotificationElement >> onTaskAnnouncement: aGtRrTaskAnnouncement [

	aGtRrTaskAnnouncement class = GtRrTaskStartedAnnouncement ifTrue: [ ^ self ].

	self updateDisplay.
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

	job := notification job.
	job
		when: GtRrTaskAnnouncement
			send: #onTaskAnnouncement: to: self.
]

{ #category : #'private - accessing' }
GtRrJobNotificationElement >> successfulCount [

	^ job successfulCount
]

{ #category : #'private - subscriptions' }
GtRrJobNotificationElement >> unsubscribeFromNotification [

	job ifNil: [ ^ self ].
	job unsubscribe: self.
	job := nil.
]

{ #category : #'private - updating' }
GtRrJobNotificationElement >> updateDisplay [
	self
		enqueueTask: (BlTaskAction new
				action: [ | states |
					nameLabel text: self name.

					isFinished
						ifFalse: [ statePane removeChildren.

							states := self constructStates.

							states do: [ :state | statePane addChild: state ].

							job isFinished
								ifTrue: [ nameLabel
										addChild: (BrGlamorousVectorIcons accept asElement asScalableElement
												addAptitude: (BrGlamorousWithLabelTooltipAptitude new text: 'Finished')).
									isFinished := true ] ] ])
]
