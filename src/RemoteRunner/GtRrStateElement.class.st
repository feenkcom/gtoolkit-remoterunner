Class {
	#name : #GtRrStateElement,
	#superclass : #BrHorizontalPane,
	#instVars : [
		'name',
		'color',
		'count',
		'elements'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #'instance creation' }
GtRrStateElement class >> name: aString color: aColor elements: aNumber [
	^ self basicNew
		name: aString;
		color: aColor;
		elements: aNumber;
		initialize
]

{ #category : #accessing }
GtRrStateElement >> color: aColor [
	color := aColor
]

{ #category : #accessing }
GtRrStateElement >> elements: aCollection [
	elements := aCollection
]

{ #category : #accessing }
GtRrStateElement >> initialize [
	| icon label amount |
	super initialize.

	self
		hMatchParent;
		vFitContent;
		alignCenterLeft.

	icon := GtPharoTestCaseUtility newColoredIcon: color.
	label := BrLabel new
			aptitude: BrGlamorousLabelAptitude;
			text: name , ':'.

	amount := BrLabel new
			aptitude: BrGlamorousLabelAptitude;
			text: elements size asString.

	self
		addChildren: {icon.
				label.
				amount}.

	self registerOnClick
]

{ #category : #accessing }
GtRrStateElement >> name: aString [
	name := aString
]

{ #category : #accessing }
GtRrStateElement >> registerOnClick [
	self
		when: BlClickEvent
		do: [ :anEvent | 
			anEvent consumed: true.
			GtInspectorTool
				openWrappedOn: elements
				title: name
				from: self ]
]
