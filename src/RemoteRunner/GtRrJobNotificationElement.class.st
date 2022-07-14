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
		'infoButton',
		'runAgainButton',
		'statePane',
		'isFinished',
		'updater'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #accessing }
GtRrJobNotificationElement >> allTasks [
	^ self currentJob tasks
]

{ #category : #'private - accessing' }
GtRrJobNotificationElement >> borderElement [
	<return: #GtNotificationBorderElement>
	^ borderElement
]

{ #category : #initialization }
GtRrJobNotificationElement >> buildNameLabel [
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
GtRrJobNotificationElement >> buildStateElement [
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
GtRrJobNotificationElement >> buildToolbar [
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

{ #category : #accessing }
GtRrJobNotificationElement >> constructStates [
	self jobDo: [ :aJob |
		^ {GtRrStateElement
			name: 'All'
			color: Color transparent
			elements: self allTasks.
		GtRrStateElement
			name: 'Success'
			color: Color lightGreen
			elements: (aJob results reject: #hasErrors).
		GtRrStateElement
			name: 'Failure'
			color: Color red
			elements: aJob resultsWithErrors.
		GtRrStateElement
			name: 'Not executed'
			color: Color veryVeryLightGray
			elements: self notExecutedTasks} ].
	^ #()
]

{ #category : #accessing }
GtRrJobNotificationElement >> currentJob [
	^ self notification job
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
	namePane := self buildNameLabel.
	statePane := self buildStateElement.
	toolbarPane := self buildToolbar.
	
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
		
	updater := BrElementUpdater2 new
		element: self
		selector: #updateContent.
]

{ #category : #initialization }
GtRrJobNotificationElement >> initializeBorderElement [
	borderElement := GtNotificationBorderElement new
		withCloseButtonAction: [ self dismiss ]
]

{ #category : #private }
GtRrJobNotificationElement >> inspectJob [
	"Inspect the receiver's job in a new tab in GtWorld"
	
	self jobDo: [ :aJob |
		GtInspectorTool
			openWrappedOn: aJob
			title: aJob name
			from: self ]
]

{ #category : #accessing }
GtRrJobNotificationElement >> jobDo: aBlock [
	self notificationDo: [ :anEvent | anEvent job ifNotNil: aBlock ]
]

{ #category : #'api - accessing' }
GtRrJobNotificationElement >> message [

	self currentJob ifNil: [ ^ '<no job>' ].
	^ String streamContents: [ :stream |
		stream
			<< 'Remain: ';
			print: (self currentJob taskCount - self currentJob successfulCount - self currentJob errorCount);
			<< ', Done: ';
			print: self currentJob successfulCount;
			<< ', Failed: ';
			print: self currentJob errorCount ]
]

{ #category : #'private - accessing' }
GtRrJobNotificationElement >> name [

	^ self currentJob name
]

{ #category : #accessing }
GtRrJobNotificationElement >> notExecutedTasks [
	^ self currentJob tasks reject: #isFinished
]

{ #category : #accessing }
GtRrJobNotificationElement >> onAddedToSceneGraph [
	super onAddedToSceneGraph.
	
	self requestUpdate.
]

{ #category : #'private - hooks' }
GtRrJobNotificationElement >> onNotificationChanged [

	self requestUpdate
]

{ #category : #'private - hooks' }
GtRrJobNotificationElement >> onTaskAnnouncement: aGtRrTaskAnnouncement [

	aGtRrTaskAnnouncement class = GtRrTaskStartedAnnouncement ifTrue: [ ^ self ].

	self requestUpdate.
]

{ #category : #'private - updating' }
GtRrJobNotificationElement >> requestUpdate [
	updater requestUpdate
]

{ #category : #private }
GtRrJobNotificationElement >> runJobAgain [
	"Create a copy of the receiver's job and run it with progress notifications"
	| jobCopy |

	jobCopy := self currentJob copy.
	jobCopy showProgressNotification.
	
	GtRemoteRunner default submitJob: jobCopy.
]

{ #category : #'private - subscriptions' }
GtRrJobNotificationElement >> subscribeToNotification [
	self jobDo: [ :aJob | 
		aJob
			when: GtRrTaskAnnouncement
			send: #onTaskAnnouncement: 
			to: self ]
]

{ #category : #'private - accessing' }
GtRrJobNotificationElement >> successfulCount [

	^ self currentJob successfulCount
]

{ #category : #'private - subscriptions' }
GtRrJobNotificationElement >> unsubscribeFromNotification [
	self jobDo: [ :aJob | 
		aJob unsubscribe: self ]	
]

{ #category : #'private - updating' }
GtRrJobNotificationElement >> updateContent [
	| states |
	
	nameLabel text: self name.
 
	"Do not update the state if the job is finished"
	isFinished ifTrue: [ ^ self ].
	
	statePane removeChildren.
	states := self constructStates.
	states do: [ :state | statePane addChild: state ].

	self jobDo: [ :aJob | 
		aJob isFinished ifTrue: [ 
			nameLabel
				addChild: (BrGlamorousVectorIcons accept asElement asScalableElement
					addAptitude: (BrGlamorousWithLabelTooltipAptitude new 
						text: 'Finished')).
			isFinished := true ] ]
]
