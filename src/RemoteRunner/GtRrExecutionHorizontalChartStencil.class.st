Class {
	#name : #GtRrExecutionHorizontalChartStencil,
	#superclass : #BrStencil,
	#instVars : [
		'executions',
		'startTimeComputation',
		'endTimeComputation',
		'rowLabelComputation',
		'colorComputation',
		'rowValuesComputation',
		'barHeight',
		'rowHeight',
		'hideRowLabels',
		'hideAxisLabels',
		'labelWidth',
		'leftPadding',
		'selectionTransformation'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> amountOfTicks [
	^ 6
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> barHeight [
	^ barHeight
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> colorComputation: anObject [

	colorComputation := anObject
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> configureWithMinimalDetails [
	barHeight := 1.
	rowHeight := 1.
	leftPadding := 20.
	
	hideRowLabels := true.
	hideAxisLabels := false.
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> create [
	<return: #Object>
	| minCreationDate maxExpireDate plot timeScale barWidthScale |
	
	minCreationDate := self firstStartDate.	
	maxExpireDate := self lastEndDate.
	
	timeScale := GtPlotterTimeScale new 
		domainFrom: minCreationDate to: maxExpireDate.
	timeScale tickFormat: [ :eachDateAndTime | 
		(eachDateAndTime - minCreationDate) gtShortPrintString ].
	
	barWidthScale := GtPlotterDurationScale new 
		domainFrom: 0 seconds 
		to: maxExpireDate - minCreationDate.
	
	plot := BrVerticalPane new 
		matchParent.
	
	hideAxisLabels ifFalse: [
		plot addChild: (self 
			createHorizontalThicksLabelsElementForTimeScale: timeScale) ].
	plot addChild: (self
		createPlotterScrollableElementForTimeScale: timeScale 
		andWidthScale: barWidthScale).

	^ plot
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> createGridlines: aGtPlotterScale [
	^ GtPlotterHorizontalTicksElement new
		padding: self gridlinePadding;
		preventMeAndChildrenMouseEvents;
		scale: aGtPlotterScale;
		tickStyle: [ :anElement | anElement
			width: self gridlineWidth;
			background: self gridlineColor ];
		ticks: self amountOfTicks
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> createHorizontalThicksLabelsElementForTimeScale: aTimeScale [
	^ (GtPlotterHorizontalTickLabelsElement new
		padding: (BlInsets 
			left: self labelWidth + self gridlineOffset + self leftPadding);
		scale: aTimeScale;
		height: 30;
		labels: self amountOfTicks)
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> createLabel: aString [
	^ BrLabel new
		aptitude:
			(BrGlamorousLabelAptitude new
				foreground: self labelColor);
		padding: (BlInsets right: 5);
		text: aString
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> createLabelCell: aString [
	^ BrVerticalPane new
		matchParent;
		alignCenterRight;
		addChild: (self createLabel: aString);
		hExact: self labelWidth
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> createPlotterScrollableElementForTimeScale: timeScale andWidthScale: barWidthScale [
	| scrollableContainer scrollableContent |
	scrollableContainer := BrFrame new 
		matchParent.
	scrollableContent := BrSimpleList new.
	scrollableContent matchParent.
	scrollableContent addEventHandler: (GtPhlowListToSelectHandler new
		transformation: selectionTransformation).
	
	scrollableContent 
		itemStencil: [
			| rowElement |
			rowElement := self createRow.
			hideRowLabels ifFalse: [
				rowElement
					addAptitude: BrGlamorousListItemAptitude new  ].
			rowElement ];
		itemDataBinder: [ :rowContainer  :anExecutionDetails |
			| rowLabel horizontalBars |
			rowContainer removeChildren.
			
			hideRowLabels ifFalse: [
				rowLabel := self createLabelCell: (rowLabelComputation 
					value: anExecutionDetails).
				rowContainer addChild: rowLabel ].
	
			horizontalBars := GtPlotterHorizontalValueBarsElement new
				height: self barHeight;
				valueStyle: [ :anElement :aGtScaleContext |
					self styleBar: anElement execution: aGtScaleContext originalValue.
					anElement constraintsDo: [ :c | 
						c frame horizontal 
							alignLeftAt: (timeScale 
								map: (startTimeComputation 
									value: aGtScaleContext originalValue)) ] ];
				scale: barWidthScale;
				scaleData: [ :each | each duration ];
				values: (rowValuesComputation cull: anExecutionDetails).
		
			rowContainer addChild: horizontalBars. ].
			
	scrollableContent items: self executions.
	
	scrollableContainer addChild: scrollableContent.
	scrollableContainer addChild: (self createGridlines: timeScale). 
	scrollableContainer padding: (BlInsets left: self leftPadding).
	
	^ scrollableContainer
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> createRow [
	^ BrHorizontalPane new
		vExact: self rowHeight;
		alignCenter;
		hMatchParent
]

{ #category : #initialization }
GtRrExecutionHorizontalChartStencil >> defaultBarColor [
	^ ((Color r: 92 g: 204 b: 231 range: 255) alpha: 0.2)
]

{ #category : #initialization }
GtRrExecutionHorizontalChartStencil >> enabledGroupsInRow [
	rowValuesComputation := [ :anExecution | anExecution items ].
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> endTimeComputation: anObject [

	endTimeComputation := anObject
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> executions [

	^ executions
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> executions: anObject [

	executions := anObject
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> firstStartDate [
	^ self executions
		inject: (startTimeComputation value: self executions first)
		into: [ :minDate :each | 
			minDate min: (startTimeComputation value: each) ]
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> gridlineColor [
	^ Color gray alpha: 0.2
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> gridlineOffset [
	^ 10
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> gridlinePadding [
	^ BlInsets left: self labelWidth + self gridlineOffset
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> gridlineWidth [
	^ 1
]

{ #category : #initialization }
GtRrExecutionHorizontalChartStencil >> initialize [
	super initialize.
	
	barHeight := 15.
	rowHeight := 20.
	labelWidth := 250.
	hideRowLabels := false.
	hideAxisLabels := false.
	leftPadding := 0.
	
	startTimeComputation := [ :anExecution | anExecution startTime ].
	endTimeComputation :=  [ :anExecution | anExecution endTime ].
	rowLabelComputation := [ :anExecution | anExecution label ].
	colorComputation := [ self defaultBarColor ].
	rowValuesComputation := [ :anExecution | {anExecution} ].
	selectionTransformation := [ :each | each ]
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> labelColor [
	^ Color gray
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> labelWidth [
	^ hideRowLabels 
		ifTrue: [ 0 ] 
		ifFalse: [ labelWidth ]
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> lastEndDate [
	^ self executions 
		inject: (endTimeComputation value: self executions  first) 
		into: [ :maxDate :each | 
			maxDate max: (endTimeComputation value: each) ]
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> leftPadding [

	^ leftPadding
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> leftPadding: anObject [

	leftPadding := anObject
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> rowHeight [
	^ rowHeight
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> rowLabelComputation [

	^ rowLabelComputation
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> rowLabelComputation: anObject [

	rowLabelComputation := anObject
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> rowValuesComputation: anObject [

	rowValuesComputation := anObject
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> selectionTransformation [

	^ selectionTransformation
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> selectionTransformation: anObject [

	selectionTransformation := anObject
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> startTimeComputation: anObject [

	startTimeComputation := anObject
]

{ #category : #accessing }
GtRrExecutionHorizontalChartStencil >> styleBar: anElement execution: anObject [ 
	^ anElement
		geometry: BlStadium new;
		background: ((colorComputation cull: anObject) ifNil: [
			self defaultBarColor ]) 
]

{ #category : #initialization }
GtRrExecutionHorizontalChartStencil >> withColorBasedOnScheduling [
	self colorComputation: [ :anItem |
					(anItem propertyAt: #correctScheduling ifAbsent: [ false ])
						ifFalse: [ Color red ] 
						ifTrue: [ Color gray ] ]
]

{ #category : #initialization }
GtRrExecutionHorizontalChartStencil >> withDescriptionAsLabel [
	rowLabelComputation := [ :anExecution | anExecution description ]
]

{ #category : #initialization }
GtRrExecutionHorizontalChartStencil >> withDissplayStringAsLabel [
	rowLabelComputation := [ :anExecution | anExecution gtDisplayString ]
]
