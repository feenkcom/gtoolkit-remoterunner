Class {
	#name : #GtRrDataGroupStateElement,
	#superclass : #BrHorizontalPane,
	#instVars : [
		'state'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #'instance creation' }
GtRrDataGroupStateElement class >> forState: aState [
	^ self new 
		state: aState
]

{ #category : #callbacks }
GtRrDataGroupStateElement >> actOnClickEvent [
	self state actOnClickFrom: self
]

{ #category : #initialization }
GtRrDataGroupStateElement >> initialize [
	super initialize.

	self
		hMatchParent;
		vFitContent;
		alignCenterLeft.

	self registerOnClick
]

{ #category : #initialization }
GtRrDataGroupStateElement >> initializeContent [
	| icon nameLabel amountLabel |
	
	icon := GtPharoTestCaseUtility newColoredIcon: self state color.
	nameLabel := BrLabel new
			aptitude: BrGlamorousLabelAptitude;
			text: self state name , ':'.

	amountLabel := BrLabel new
			aptitude: BrGlamorousLabelAptitude;
			text: self state itemCount asString.

	self
		addChildren: {
			icon.
			nameLabel.
			amountLabel}.
]

{ #category : #initialization }
GtRrDataGroupStateElement >> registerOnClick [
	self
		when: BlClickEvent
		do: [ :anEvent | 
			anEvent consumed: true.
			self state ifNotNil: [
				self actOnClickEvent ] ]
]

{ #category : #accessing }
GtRrDataGroupStateElement >> state [
	^ state
]

{ #category : #accessing }
GtRrDataGroupStateElement >> state: aState [ 
	self assert: [ state isNil ].
	
	state := aState.
	self initializeContent.
]
