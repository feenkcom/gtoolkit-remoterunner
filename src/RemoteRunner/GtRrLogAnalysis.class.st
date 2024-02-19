Class {
	#name : #GtRrLogAnalysis,
	#superclass : #Object,
	#instVars : [
		'logger',
		'grouper',
		'eventsGroup',
		'signals',
		'strictMode'
	],
	#category : #'RemoteRunner-Analysis'
}

{ #category : #accessing }
GtRrLogAnalysis >> description [

	^ 'A Job Description'
]

{ #category : #accessing }
GtRrLogAnalysis >> eventsGroup [

	^ eventsGroup ifNil: [ eventsGroup := self grouper eventsGroup ]
]

{ #category : #ui }
GtRrLogAnalysis >> executionTimelineChartItems [
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
GtRrLogAnalysis >> grouper [
	^ grouper ifNil:
		[ grouper := "GtBeaconEventsGrouper" GtFlatEventsGrouper new.
		grouper strictMode: strictMode.
		grouper processEventSignalsFor: self jobSignals.
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

{ #category : #ui }
GtRrLogAnalysis >> gtViewExecutionTimelineListFor: aView [
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
							colorComputation: [ :anItem | nil ] ] ]
]

{ #category : #accessing }
GtRrLogAnalysis >> initialize [

	super initialize.
	strictMode := true.
]

{ #category : #accessing }
GtRrLogAnalysis >> jobSignals [
	| i relevantRecordings |

	relevantRecordings := OrderedCollection new.
	i := 1.
	[ | recording |
	recording := signals at: i.
	((recording respondsTo: #signalTypeLabel) and:
		[ recording signalTypeLabel ~= 'LwGtRrSignal' ]) ifTrue:
			[ relevantRecordings add: recording ].
	i := i + 1.
	recording class ~= LwGtRrJobManagerJobCompletedSignal
		and: [ i <= signals size ] ] whileTrue.
	^ relevantRecordings.
]

{ #category : #accessing }
GtRrLogAnalysis >> logger [
	^ logger
]

{ #category : #accessing }
GtRrLogAnalysis >> logger: aSignalLogger [

	logger := aSignalLogger.
	signals := aSignalLogger recordings.
]

{ #category : #accessing }
GtRrLogAnalysis >> signals [
	^ signals
]

{ #category : #accessing }
GtRrLogAnalysis >> signals: anObject [
	signals := anObject
]

{ #category : #accessing }
GtRrLogAnalysis >> strictMode [
	^ strictMode
]

{ #category : #accessing }
GtRrLogAnalysis >> strictMode: anObject [
	strictMode := anObject
]

{ #category : #accessing }
GtRrLogAnalysis >> subEvents [

	^ self eventsGroup first subEvents
]

{ #category : #accessing }
GtRrLogAnalysis >> totalDuration [

	^ self eventsGroup first duration
]
