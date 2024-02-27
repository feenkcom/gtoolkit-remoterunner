Class {
	#name : #GtRemoteRunnerLogAnalysis,
	#superclass : #Object,
	#instVars : [
		'grouper',
		'signals',
		'strictMode',
		'logEvent',
		'eventLabel'
	],
	#category : #'RemoteRunner-Analysis'
}

{ #category : #accessing }
GtRemoteRunnerLogAnalysis >> description [

	^ self subclassResponsibility
]

{ #category : #accessing }
GtRemoteRunnerLogAnalysis >> eventLabel [
	^ eventLabel ifNil: [ self description ]
]

{ #category : #accessing }
GtRemoteRunnerLogAnalysis >> eventLabel: anObject [
	eventLabel := anObject
]

{ #category : #accessing }
GtRemoteRunnerLogAnalysis >> eventSignals [

	^ signals select: [ :each |
		each respondsTo: #signalTypeLabel ]
]

{ #category : #ui }
GtRemoteRunnerLogAnalysis >> executionTimelineChartItems [
	| tenMs |

	tenMs := 10 milliSeconds.
	^ self eventsGroup allEvents
		select: [ :each | each duration > tenMs ]
		thenCollect: [ :each | | item |
			item := GtRrExecutionChartDataItem new
				startTime: each startTimestamp;
				endTime: each endTimestamp;
				label: each description;
				appendDurationToLabel.
			item propertyAt: #source put: each.
			item ]
]

{ #category : #accessing }
GtRemoteRunnerLogAnalysis >> grouper [
	^ grouper ifNil:
		[ grouper := GtFlatEventsGrouper new.
		grouper strictMode: strictMode.
		grouper processEventSignalsFor: self eventSignals.
		grouper ].
]

{ #category : #ui }
GtRemoteRunnerLogAnalysis >> gtBarElements [
	^ (self gtBarElementsWithGlobalWeight: 1.0 local: 1.0) asScrollableElement
		margin: (BlInsets all: 10)
]

{ #category : #ui }
GtRemoteRunnerLogAnalysis >> gtBarElementsWithGlobalWeight: aWeight local: aLocalWeight [
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
GtRemoteRunnerLogAnalysis >> gtItemsFor: aView [
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
GtRemoteRunnerLogAnalysis >> gtMapFor: aView [
	<gtView>

	^ aView explicit
		title: 'Duration map';
		priority: 20;
		stencil: [ self gtBarElements ]
]

{ #category : #ui }
GtRemoteRunnerLogAnalysis >> gtViewExecutionTimelineListFor: aView [
	<gtView>
	^self executionTimelineChartItems
		ifEmpty: [aView empty]
		ifNotEmpty: [ :currentTimelineData |
			aView explicit
				title: 'Job Execution Timeline';
				priority: 30;
				stencil: 
						[(GtRrExecutionHorizontalChartStencil new)
							executions: currentTimelineData;
							colorComputation: [ :anItem |
								(Color r: 92 g: 204 b: 231 range: 255) ] ] ]
]

{ #category : #accessing }
GtRemoteRunnerLogAnalysis >> initialize [

	super initialize.
	strictMode := true.
]

{ #category : #accessing }
GtRemoteRunnerLogAnalysis >> logEvent [
	| subEvents zero |
	
	logEvent ifNotNil: [ ^ logEvent ].

	zero := Duration zero.
	subEvents := self grouper eventsGroup
		select: [ :each | each duration > zero ].
	logEvent := GtBeaconGenericLogCompositeEvent new
		eventLabel: self eventLabel;
		addSubEvents: subEvents.
	^ logEvent
]

{ #category : #accessing }
GtRemoteRunnerLogAnalysis >> signals [
	
	^ signals
]

{ #category : #accessing }
GtRemoteRunnerLogAnalysis >> signals: anObject [
	signals := anObject
]

{ #category : #accessing }
GtRemoteRunnerLogAnalysis >> strictMode [
	^ strictMode
]

{ #category : #accessing }
GtRemoteRunnerLogAnalysis >> strictMode: anObject [
	strictMode := anObject
]

{ #category : #accessing }
GtRemoteRunnerLogAnalysis >> subEvents [

	^ self eventsGroup first subEvents
]

{ #category : #accessing }
GtRemoteRunnerLogAnalysis >> totalDuration [

	^ self eventsGroup first duration
]
