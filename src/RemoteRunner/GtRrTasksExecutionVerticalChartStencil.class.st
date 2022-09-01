Class {
	#name : #GtRrTasksExecutionVerticalChartStencil,
	#superclass : #BrStencil,
	#instVars : [
		'tasksGroup'
	],
	#category : #'RemoteRunner-Tasks'
}

{ #category : #accessing }
GtRrTasksExecutionVerticalChartStencil >> create [
	| timelineScale barsScale container histogram labels ticks |
	
	timelineScale := self timelineScale.
	barsScale := GtPlotterDurationScale new
		domainFrom: 0 milliSeconds
		to: (self tasksGroup maxValue: #duration).

	histogram := self createHistogramChartWithScale: barsScale.
	labels := self createLabelsElementWithScale: barsScale.
	ticks := self createThicksElementWithScale: barsScale.

	container := BrVerticalPane new matchParent.
	container
		addChild: labels;
		addChild: (BrFrame new
			matchParent;
			addChild: histogram;
			addChild: ticks).
			
	^ container
]

{ #category : #accessing }
GtRrTasksExecutionVerticalChartStencil >> createHistogramChartWithScale: barsScale [
	^ BlElement new
		margin: (BlInsets left: 50);
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ];
		geometry: (BlHistogram new
			beLeftToRight;
			values: (self tasksGroup 
				collect: [ :aTask | 
					(barsScale map: aTask duration) min: 1 ]));
		background: (BlLinearGradientPaint horizontal
				stops: {0.2 -> Color red.
						1 -> (Color red alpha: 0.0)})
]

{ #category : #accessing }
GtRrTasksExecutionVerticalChartStencil >> createLabelsElementWithScale: barsScale [
	^ GtPlotterHorizontalTickLabelsElement new
		clipChildren: false;
		scale: barsScale;
		padding: (BlInsets left: 50);
		constraintsDo: [ :c | c vertical fitContent ];
		labelElement: [ :aGtPlotterScaleContext | 
			BrLabel new
				aptitude: (BrLabelAptitude new 
					foreground: Color gray);
				text: (aGtPlotterScaleContext scale
					formattedTick: aGtPlotterScaleContext originalValue) ];
		labels: 5
]

{ #category : #accessing }
GtRrTasksExecutionVerticalChartStencil >> createThicksElementWithScale: barsScale [
	^ GtPlotterHorizontalTicksElement new
		padding: (BlInsets left: 50);
		preventMeAndChildrenMouseEvents;
		scale: barsScale;
		tickStyle: [ :anElement | 
			anElement
				width: 2;
				background: (Color gray alpha: 0.2) ];
		ticks: 5
]

{ #category : #accessing }
GtRrTasksExecutionVerticalChartStencil >> tasksGroup [
	^ tasksGroup
]

{ #category : #accessing }
GtRrTasksExecutionVerticalChartStencil >> tasksGroup: aTasksGroup [
	tasksGroup := aTasksGroup
]

{ #category : #accessing }
GtRrTasksExecutionVerticalChartStencil >> timelineScale [
	| endTime startTime offset |
	
	startTime := self tasksGroup startTime.
	endTime := self tasksGroup endTime.
	offset := (endTime - startTime) * 0.1.
	
	^ GtPlotterTimeScale new domainFrom: startTime - offset to: endTime + offset
]
