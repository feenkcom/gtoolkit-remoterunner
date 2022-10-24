"
{{gtClass:name=GtRrTasksExecutionHorizontalChartStencil}} is a stencil that creates a chart showing the duration of tasks. 

It works in tandem  with  a collection of {{gtClass:name=GtRrTask}} or  {{gtClass:name=GtRrExecutionChartDataItem}} instances set using {{gtMethod:name=GtRrTasksExecutionHorizontalChartStencil>>taskItems:|label=#selector}}. It is compatible with {{gtClass:name=GtRrExecutionChartDataItem}}  provides an alternative to using proxies to tasks.
"
Class {
	#name : #GtRrTasksExecutionHorizontalChartStencil,
	#superclass : #BrStencil,
	#instVars : [
		'taskItems'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #accessing }
GtRrTasksExecutionHorizontalChartStencil >> create [
	| timelineScale barsScale container histogram labels ticks |
	
	timelineScale := self timelineScale.
	barsScale := GtPlotterDurationScale new
		domainFrom: 0 milliSeconds
		to: self maximumTaskDuration.

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
GtRrTasksExecutionHorizontalChartStencil >> createHistogramChartWithScale: barsScale [
	^ BlElement new
		margin: (BlInsets left: 50);
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ];
		geometry: (BlHistogram new
			beLeftToRight;
			values: (self taskItems 
				collect: [ :aTaskOrItem | 
					(barsScale map: aTaskOrItem duration) min: 1 ]));
		background: (BlLinearGradientPaint horizontal
			stops: {
				0.2 -> Color red.
				1 -> (Color red alpha: 0.0)})
]

{ #category : #accessing }
GtRrTasksExecutionHorizontalChartStencil >> createLabelsElementWithScale: barsScale [
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
GtRrTasksExecutionHorizontalChartStencil >> createThicksElementWithScale: barsScale [
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
GtRrTasksExecutionHorizontalChartStencil >> maximumTaskDuration [
	^ self taskItems maxValue: #duration
]

{ #category : #accessing }
GtRrTasksExecutionHorizontalChartStencil >> taskItems [

	^ taskItems
]

{ #category : #accessing }
GtRrTasksExecutionHorizontalChartStencil >> taskItems: aCollection [

	taskItems := aCollection
]

{ #category : #accessing }
GtRrTasksExecutionHorizontalChartStencil >> tasksEndTime [
	^ self taskItems maxValue: #endTime
]

{ #category : #accessing }
GtRrTasksExecutionHorizontalChartStencil >> tasksStartTime [
	^ self taskItems maxValue: #startTime
]

{ #category : #accessing }
GtRrTasksExecutionHorizontalChartStencil >> timelineScale [
	| endTime startTime offset |
	
	startTime := self tasksStartTime.
	endTime := self  tasksEndTime.
	offset := (endTime - startTime) * 0.1.
	
	^ GtPlotterTimeScale new 
		domainFrom: startTime - offset 
		to: endTime + offset
]
