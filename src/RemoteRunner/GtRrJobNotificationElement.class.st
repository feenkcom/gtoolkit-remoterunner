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
		'isFinished',
		'updater',
		'statesPane'
	],
	#category : #'RemoteRunner-Jobs-Notifications'
}

{ #category : #accessing }
GtRrJobNotificationElement >> actOnElementDetached [
	self clearNotification.
	self clearContent.
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
GtRrJobNotificationElement >> buildStatesElement [
	^ BrVerticalPane new
		margin: (BlInsets bottom: 5);
		hMatchParent;
		vFitContent
]

{ #category : #initialization }
GtRrJobNotificationElement >> buildToolbar [
	| horizontalPane  toolbarButtons |
	
	horizontalPane := BrHorizontalPane new
			hMatchParent;
			vFitContent;
			alignCenterRight.
			
	toolbarButtons := self buildToolbarButtons.
	
	horizontalPane
		addChildren: toolbarButtons.
	^ horizontalPane
]

{ #category : #initialization }
GtRrJobNotificationElement >> buildToolbarButtons [
	| infoButton runAgainButton |
	
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
			
	^ {infoButton. runAgainButton}
]

{ #category : #'private - hooks' }
GtRrJobNotificationElement >> clearContent [
	nameLabel text: '<noJob>'.
	nameLabel removeChildNamed: #statusIcon.
	statesPane removeChildren.
]

{ #category : #accessing }
GtRrJobNotificationElement >> constructStateElements [
	^ self constructStates collect: [ :aDataGroupState |
		GtRrDataGroupStateElement forState: aDataGroupState ]
]

{ #category : #accessing }
GtRrJobNotificationElement >> constructStates [
	self notificationDo: [ :aNotification |
		^ aNotification constructStates ].
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
	statesPane := self buildStatesElement.
	toolbarPane := self buildToolbar.
	
	self addChild: self borderElement as: #border.
	self borderElement containerDo: [ :aContainer |
		aContainer 
			addChild: namePane;
			addChild: statesPane;
			addChild: toolbarPane ].
	
	self addAptitude: (BrLayoutResizerAptitude new
		hInherit;
		vAnyToFitContent;
		hInherit: self borderElement;
		vAnyToFitContent: self borderElement;
		hInherit: statesPane;
		vAnyToFitContent: statesPane).
		
	updater := BrElementUpdater new
		element: self
		selector: #updateContent.
	updater postponedDuration: 1 seconds.
]

{ #category : #initialization }
GtRrJobNotificationElement >> initializeBorderElement [
	borderElement := GtNotificationBorderElement new
		withCloseButtonAction: [ self dismiss ]
]

{ #category : #private }
GtRrJobNotificationElement >> inspectJob [
	"Inspect the receiver's job in a new tab in GtWorld"
	
	self notificationDo: [ :aNotification |
		aNotification spawnInspectToolFromSource: self ]
]

{ #category : #accessing }
GtRrJobNotificationElement >> jobDo: aBlock [
	self notificationDo: [ :anEvent | anEvent job ifNotNil: aBlock ]
]

{ #category : #'private - accessing' }
GtRrJobNotificationElement >> name [
	self notificationDo: [ :aNotification | 
		^ aNotification notificationLabel ].
	^ '<missing job>'
]

{ #category : #accessing }
GtRrJobNotificationElement >> notification: aGtNotificationEvent [
	isFinished := false.
	
	super notification: aGtNotificationEvent
]

{ #category : #accessing }
GtRrJobNotificationElement >> onAddedToSceneGraph [
	super onAddedToSceneGraph.
	
	self requestUpdate.
]

{ #category : #'private - hooks' }
GtRrJobNotificationElement >> onNotificationChanged [
	self clearContent.
	self requestUpdate
]

{ #category : #'private - hooks' }
GtRrJobNotificationElement >> onNotificationDataChangedFor: anAnnouncement [
	self requestUpdate
]

{ #category : #'private - updating' }
GtRrJobNotificationElement >> requestUpdate [
	updater requestUpdate
]

{ #category : #private }
GtRrJobNotificationElement >> runJobAgain [
	self notificationDo: [ :aNotification |
		aNotification runJobAgain ]
]

{ #category : #subscriptions }
GtRrJobNotificationElement >> subscribeToNotification [
	self notificationDo: [ :aNotification | 
		aNotification
			when: GtNotificationDataChangedAnnouncement
			send: #onNotificationDataChangedFor: 
			to: self ]
]

{ #category : #'private - accessing' }
GtRrJobNotificationElement >> successfulCount [

	^ self currentJob successfulCount
]

{ #category : #'private - subscriptions' }
GtRrJobNotificationElement >> unsubscribeFromNotification [
	self notificationDo: [ :aNotification | 
		aNotification unsubscribe: self ]	
]

{ #category : #'private - updating' }
GtRrJobNotificationElement >> updateContent [
	
	self updateLabelContent.
 
	"Do not update the state if the job is finished"
	isFinished ifTrue: [ ^ self ].
	
	self jobDo: [ :aJob | 
		"If the job is finished do a final update of the states."
		aJob isFinished ifTrue: [ 
			self updateStates.
			self updateLabelStatusIcon.
			isFinished := true.
			
			^ self ].
		
		"If the job is not finished yet we update the state."
		self updateStates ]
]

{ #category : #'private - updating' }
GtRrJobNotificationElement >> updateLabelContent [
	nameLabel text: self name.
]

{ #category : #'private - updating' }
GtRrJobNotificationElement >> updateLabelStatusIcon [
	nameLabel removeChildNamed: #statusIcon.
	nameLabel
		addChild: (BrGlamorousVectorIcons accept asElement asScalableElement
			addAptitude: (BrGlamorousWithLabelTooltipAptitude new 
				text: 'Finished'))
		as: #statusIcon.
]

{ #category : #'private - updating' }
GtRrJobNotificationElement >> updateStates [
	| stateElements |
	statesPane removeChildren.
	stateElements := self constructStateElements.
	stateElements do: [ :state | statesPane addChild: state ].
]
