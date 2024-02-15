Class {
	#name : #GtRrLogAnalysis,
	#superclass : #Object,
	#instVars : [
		'logger',
		'grouper',
		'eventsGroup'
	],
	#category : #'RemoteRunner-Analysis'
}

{ #category : #accessing }
GtRrLogAnalysis >> analyze [
	| i relevantRecordings recordings |

	recordings := logger recordings.
	relevantRecordings := OrderedCollection new.
	i := 1.
	[ | recording |
	recording := recordings at: i.
	((recording respondsTo: #signalTypeLabel) and:
		[ recording signalTypeLabel ~= 'LwGtRrSignal' ]) ifTrue:
			[ relevantRecordings add: recording ].
	i := i + 1.
	recording class = LwGtRrJobManagerJobCompletedSignal ] whileFalse.
	grouper processEventSignalsFor: relevantRecordings.

]

{ #category : #accessing }
GtRrLogAnalysis >> description [

	^ 'A Job Description'
]

{ #category : #accessing }
GtRrLogAnalysis >> eventsGroup [

	^ eventsGroup ifNil: [ eventsGroup := self grouper rootEvents ]
]

{ #category : #accessing }
GtRrLogAnalysis >> grouper [
	^ grouper ifNil:
		[ grouper := GtBeaconEventsGrouper new.
		self analyze.
		grouper ].
]

{ #category : #ui }
GtRrLogAnalysis >> gtBarElements [
	^ (self gtBarElementsWithGlobalWeight: 1.0 local: 1.0) asScrollableElement
		margin: (BlInsets all: 10)
]

{ #category : #ui }
GtRrLogAnalysis >> gtBarElementsWithGlobalWeight: aWeight local: aLocalWeight [
	| taskElements aBarColor |
	
	aBarColor := BlColorTransition interpolate: Color veryLightGray to: BrGlamorousColors errorBorderColor at: aWeight.
	
	taskElements := aWeight > 0.1
		ifTrue: [
			| myDuration |		
			myDuration := self totalDuration.
	
			self subEvents collect: [ :anEvent |
				| eachWeight |
				
				eachWeight := myDuration isZero
					ifTrue: [ 0 ]
					ifFalse: [ (anEvent totalDuration / myDuration) asFloat ].
				(anEvent gtBarElementsWithGlobalWeight: eachWeight * aWeight local: eachWeight)
					constraintsDo: [ :c | c linear weight: (eachWeight max: 0.001) ] ] ]
		ifFalse: [
			self subEvents
				ifEmpty: [ #() ]
				ifNotEmpty: [ {
					BlElement new
						layout: BlLinearLayout horizontal;
						constraintsDo: [ :c |
							c horizontal matchParent.
							c vertical exact: 20 ];
						when: BlClickEvent
						do: [ :anEvent |
							anEvent consumed: true.
							anEvent currentTarget phlow spawnObject: self ];
						geometry: (BlRoundedRectangleGeometry cornerRadius: 3);
						border: (BlBorder paint: Color transparent width: (aWeight max: 0.1));
						background: (BlLinearGradientPaint vertical stops: {
							0 -> aBarColor.
							0.4 -> (aBarColor alpha: 0.5).
							1 -> (aBarColor alpha: 0)}) } ] ].
	
	^ BlElement new
		layout: BlLinearLayout vertical;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		addChild: (BlElement new
			layout: BlLinearLayout horizontal alignCenter;
			when: BlClickEvent
			do: [ :anEvent |
				anEvent consumed: true.
				anEvent currentTarget phlow spawnObject: self ];
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical exact: 20 ];
			padding: (BlInsets top: 3 bottom: 3);
			geometry: (BlRoundedRectangleGeometry cornerRadius: 3);
			border: (BlBorder paint: Color transparent width: 0.25);
			background: aBarColor;
			in: [ :aPane | aWeight > 0.005
				ifTrue: [ aPane addChild: (BrLabel new
					aptitude: (BrGlamorousLabelAptitude new fontSize: 10);
					text: self description) asScalableElement ] ];
			yourself);
		addChild: (BlElement new
			layout: (BlLinearLayout horizontal alignTopCenter weightSum: 1);
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical fitContent ];
			addChildren: taskElements);
		yourself
]

{ #category : #ui }
GtRrLogAnalysis >> gtItemsFor: aView [
	<gtView>
	
	^ aView columnedTree
		title: 'Events';
		priority: 10;
		items: [ self eventsGroup ];
		children: #subEvents;
		column: 'Event' text: [ :anEvent | anEvent eventStartedSignal signalTypeLabel ];
		column: 'Timestamp' text: #timestamp;
		column: 'Duration' 
			text: [ :anEvent | anEvent duration ]
]

{ #category : #ui }
GtRrLogAnalysis >> gtMapFor: aView [
	<gtView>

	^ aView explicit
		title: 'Duration map';
		priority: 20;
		stencil: [ self gtBarElements ]
]

{ #category : #accessing }
GtRrLogAnalysis >> logger [
	^ logger
]

{ #category : #accessing }
GtRrLogAnalysis >> logger: anObject [
	logger := anObject
]

{ #category : #accessing }
GtRrLogAnalysis >> subEvents [

	^ self eventsGroup first subEvents
]

{ #category : #accessing }
GtRrLogAnalysis >> totalDuration [

	^ self eventsGroup first duration
]
