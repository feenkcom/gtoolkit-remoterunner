Class {
	#name : #GtRrTasksGroup,
	#superclass : #Object,
	#traits : 'TGtGroup',
	#classTraits : 'TGtGroup classTrait',
	#instVars : [
		'items'
	],
	#category : #'RemoteRunner-Tasks'
}

{ #category : #'instance creation' }
GtRrTasksGroup class >> withAll: aCollection [
	^ self new
		initializeWith: aCollection
]

{ #category : #accessing }
GtRrTasksGroup >> endTime [ 
	| time |
	time := self items first endTime.
	self do: [ :aTask | 
		(aTask endTime notNil and: [ aTask endTime > time ])
			ifTrue: [
				time := aTask endTime ] ].
	^ time
]

{ #category : #'gt - extensions' }
GtRrTasksGroup >> gtViewTasksFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Tasks';
		priority: 10; 
		items: [ self ];
		column: 'Type' text: [ :aTask | aTask className ] width: 200;
		column: 'Task' text: [ :aTask | aTask supplementalDescription ];
		column: 'Duration' text: [ :aTask | 
			aTask duration ifNil: [ '-' ] ] width: 150
]

{ #category : #'gt - extensions' }
GtRrTasksGroup >> gtViewTimelineFor: aView [
	<gtView>
	^ aView explicit
		title: 'Timeline (v1)';
		priority: 15; 
		stencil: [
			| startTime endTime offset aPlotter |
			startTime := self startTime.
			endTime := self endTime.
			offset :=  (endTime - startTime) * 0.1.
			aPlotter := GtPlotter new.
			aPlotter horizontalTimeline
				withProjectionAxis;
				timelineData: [ :aTask | aTask startTime ];
				timelineLabelFormat: [ :aDateAndTime | aDateAndTime asTime print24 ];
				projectionData: [ :aTask | '' ];
				timelineFrom: startTime  - offset
					to: endTime + offset;
				with: self ]
]

{ #category : #'gt - extensions' }
GtRrTasksGroup >> gtViewTimelineV2For: aView [
	<gtView>
	^ aView explicit
		title: 'Timeline (v2)';
		priority: 15; 
		stencil: [
			| startTime endTime offset markers scale |
			startTime := self startTime.
			endTime := self endTime.
			offset :=  (endTime - startTime) * 0.1.
			
			scale := GtPlotterTimeScale new
					domainFrom: startTime  - offset to: endTime + offset. 
			
			markers := GtPlotterMarkersElement new
					scaleY: scale;
					x: [ :each | 0.5 ];
					y: [ :assoc | assoc key = #start 
						ifTrue: [ assoc value startTime ]
						ifFalse: [ assoc value endTime ] ];
					"constraintsDo: [ :c | c vertical fitContent ];"
					markerStyle: [ :anElement :context |
						| background |
						
						background := context originalValue  key = #start 
							ifTrue: [ Color gray ]
							ifFalse: [ Color blue ].
						anElement
							size: 8@8;
							background: (background alpha: 0.4) ];
					horizontalMarkerLayout;
					values: ((self items  select: #isFinished) flatCollect: [ :aTask |
						{ #start -> aTask.
						 #stop -> aTask }  ]).
			BrFrame new
				matchParent;
				alignCenter;
				addChild: markers;
				yourself  ]
]

{ #category : #'gt - extensions' }
GtRrTasksGroup >> gtViewTimelineV3For: aView [
	<gtView>
	^ aView explicit
		title: 'Timeline (v3)';
		priority: 20; 
		stencil: [
			| startTime endTime offset markers scale finishedTasks barWidthScale container histogram labels ticks |
			
			startTime := self startTime.
endTime := self endTime.
offset :=  (endTime - startTime) * 0.1.
			
scale := GtPlotterTimeScale new
		domainFrom: startTime  - offset to: endTime + offset. 

finishedTasks := self select: #isFinished.

barWidthScale := GtPlotterDurationScale new
	domainFrom: 0 milliseconds
	to: (finishedTasks maxValue: #duration) .

container := BrVerticalPane new
	matchParent.
	
histogram := BlElement new
	margin: (BlInsets left: 50);
	constraintsDo: [ :c | 
		c horizontal matchParent.
		c vertical matchParent ];
	geometry: (BlHistogram new
		beLeftToRight; 
		values: ((finishedTasks 
			sorted: [ :aTask | aTask duration ] descending)
			collect: [ :aTask | 
				(barWidthScale map: aTask duration ) min: 1  ]));
	background: (BlLinearGradientPaint horizontal
		stops: {
			(0.2 -> Color red).
			(1 -> (Color red alpha: 0.0))}).
			
labels := (GtPlotterHorizontalTickLabelsElement new
	clipChildren: false;
	scale: barWidthScale;
	padding: (BlInsets left: 50);
	constraintsDo: [ :c | c vertical fitContent ];
	labelElement: [ :aGtPlotterScaleContext | 
		BrLabel new
			aptitude: (BrLabelAptitude new
				foreground: Color gray);
			text: (aGtPlotterScaleContext scale
				formattedTick: aGtPlotterScaleContext originalValue) ];
			labels: 5).
			
			
ticks := (GtPlotterHorizontalTicksElement new
						padding: (BlInsets left: 50);
						preventMeAndChildrenMouseEvents;
						scale: barWidthScale;
						tickStyle: [ :anElement | 
							anElement
								width: 2;
								background: (Color gray alpha: 0.2) ];
						ticks: 5).
container 
	addChild: labels;
	addChild: (BrFrame new
				matchParent;
				addChild: histogram;
			addChild: ticks)
	
													  ]
]

{ #category : #'gt - extensions' }
GtRrTasksGroup >> gtViewTimelineV4For: aView [
	<gtView>
	^ aView explicit
		title: 'Timeline (v4)';
		priority: 20; 
		stencil: [
			| startTime endTime offset markers scale finishedTasks barWidthScale container histogram labels ticks |
			
			startTime := self startTime.
endTime := self endTime.
offset :=  (endTime - startTime) * 0.1.
			
scale := GtPlotterTimeScale new
		domainFrom: startTime  - offset to: endTime + offset. 

finishedTasks := self select: #isFinished.

barWidthScale := GtPlotterDurationScale new
	domainFrom: 0 milliseconds
	to: (finishedTasks maxValue: #duration) .

container := BrVerticalPane new
	matchParent.
	
histogram := BlElement new
	margin: (BlInsets left: 50);
	constraintsDo: [ :c | 
		c horizontal matchParent.
		c vertical matchParent ];
	geometry: (BlHistogram new
		beLeftToRight; 
		values: ((finishedTasks 
			"sorted: [ :aTask | aTask duration ] descending")
			collect: [ :aTask | 
				(barWidthScale map: aTask duration ) min: 1  ]));
	background: (BlLinearGradientPaint horizontal
		stops: {
			(0.2 -> Color red).
			(1 -> (Color red alpha: 0.0))}).
			
labels := (GtPlotterHorizontalTickLabelsElement new
	clipChildren: false;
	scale: barWidthScale;
	padding: (BlInsets left: 50);
	constraintsDo: [ :c | c vertical fitContent ];
	labelElement: [ :aGtPlotterScaleContext | 
		BrLabel new
			aptitude: (BrLabelAptitude new
				foreground: Color gray);
			text: (aGtPlotterScaleContext scale
				formattedTick: aGtPlotterScaleContext originalValue) ];
			labels: 5).
			
			
ticks := (GtPlotterHorizontalTicksElement new
						padding: (BlInsets left: 50);
						preventMeAndChildrenMouseEvents;
						scale: barWidthScale;
						tickStyle: [ :anElement | 
							anElement
								width: 2;
								background: (Color gray alpha: 0.2) ];
						ticks: 5).
container 
	addChild: labels;
	addChild: (BrFrame new
				matchParent;
				addChild: histogram;
			addChild: ticks)
	
													  ]
]

{ #category : #initialization }
GtRrTasksGroup >> initialize [
	super initialize.
	items := OrderedCollection new
]

{ #category : #initialization }
GtRrTasksGroup >> initializeWith: aCollection [
	items := aCollection
]

{ #category : #accessing }
GtRrTasksGroup >> items [
	^ items
]

{ #category : #accessing }
GtRrTasksGroup >> startTime [ 
	| time |
	time := self items first startTime.
	self do: [ :aTask |
		(aTask startTime notNil and: [ aTask startTime < time ])
			ifTrue: [
				time := aTask startTime ] ].
	^ time
]
