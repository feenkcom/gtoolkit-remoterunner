"
{{gtClass:name=GtRrTasksExecutionVerticalChartStencil}} is a stencil that creates a chart showing the duration of tasks. 

It works in tandem  with  a collection of {{gtClass:name=GtRrTask}} or  {{gtClass:name=GtRrTasksExecutionChartTaskDataModel}} instances set using {{gtMethod:name=GtRrTasksExecutionVerticalChartStencil>>taskItems:|label=#selector}}. It is compatible with {{gtClass:name=GtRrTasksExecutionChartTaskDataModel}}  provides an alternative to using proxies to tasks.
"
Class {
	#name : #GtRrTasksExecutionVerticalChartStencil,
	#superclass : #BrStencil,
	#instVars : [
		'taskItems'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #accessing }
GtRrTasksExecutionVerticalChartStencil >> create [
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
GtRrTasksExecutionVerticalChartStencil >> createHistogramChartWithScale: barsScale [
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
GtRrTasksExecutionVerticalChartStencil >> maximumTaskDuration [
	^ self taskItems maxValue: #duration
]

{ #category : #accessing }
GtRrTasksExecutionVerticalChartStencil >> taskItems [

	^ taskItems
]

{ #category : #accessing }
GtRrTasksExecutionVerticalChartStencil >> taskItems: aCollection [

	taskItems := aCollection
]

{ #category : #accessing }
GtRrTasksExecutionVerticalChartStencil >> tasksEndTime [
	^ self taskItems maxValue: #endTime
]

{ #category : #accessing }
GtRrTasksExecutionVerticalChartStencil >> tasksStartTime [
	^ self taskItems maxValue: #startTime
]

{ #category : #accessing }
GtRrTasksExecutionVerticalChartStencil >> timelineScale [
	| endTime startTime offset |
	
	startTime := self tasksStartTime.
	endTime := self  tasksEndTime.
	offset := (endTime - startTime) * 0.1.
	
	^ GtPlotterTimeScale new 
		domainFrom: startTime - offset 
		to: endTime + offset
]
