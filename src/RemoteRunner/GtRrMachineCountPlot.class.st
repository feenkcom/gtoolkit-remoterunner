Class {
	#name : #GtRrMachineCountPlot,
	#superclass : #Object,
	#instVars : [
		'values',
		'minX',
		'maxX',
		'minY',
		'maxY'
	],
	#category : #'RemoteRunner-Analysis'
}

{ #category : #'example - axis' }
GtRrMachineCountPlot >> axisX [

	^ BrVerticalPane new
		vFitContent;
		hMatchParent;
		clipChildren: false;
		addChildren: { 
			self axisXTicks height: 10.
			self axisXLabels.
			self axisXName.
		}
]

{ #category : #accessing }
GtRrMachineCountPlot >> axisXkey [
	^'Minutes'
]

{ #category : #accessing }
GtRrMachineCountPlot >> axisXLabels [
	
	^ GtPlotterHorizontalTickLabelsElement new
		scale: self scaleX;
		labelFormat: [ :eachDateAndTime | | duration |
			duration := eachDateAndTime - minX.
			(duration asSeconds / 60) rounded printString
				asRopedText foreground: Color darkGray ];
		constraintsDo: [ :c | c vertical fitContent ];
		clipChildren: false;
		labels: 10
]

{ #category : #'example - axis' }
GtRrMachineCountPlot >> axisXLine [
	
	^ BlElement new
		height: 2;
		background: (Color veryVeryLightGray);
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c frame vertical alignBottom ]
]

{ #category : #'example - axis' }
GtRrMachineCountPlot >> axisXName [

	^(BrLabel new)
		aptitude: ((BrGlamorousLabelAptitude new)
					glamorousRegularFont;
					foreground: Color darkGray;
					fontSize: 16);
		text: self axisXkey;
		constraintsDo: [:c | c linear horizontal alignRight]
]

{ #category : #accessing }
GtRrMachineCountPlot >> axisXProjectionLabels [

	^ self corner
]

{ #category : #'example - axis' }
GtRrMachineCountPlot >> axisXProjections [

	^ GtPlotterHorizontalValueProjectionsElement new
		scale: self scaleX;
		scaleData: #key;
		valueStyle: [ :anElement :aGtPlotterScaleContext | 
			anElement 
				background: (aGtPlotterScaleContext originalValue value > 30
					ifTrue: [ Color red ]
					ifFalse: [ Color veryLightGray ]) ];
		values: self peekCommits
]

{ #category : #'example - axis' }
GtRrMachineCountPlot >> axisXTicks [
	
	^ GtPlotterHorizontalTicksElement new
		scale: self scaleX;
		tickStyle: [ :anElement | anElement
			width: 2;
			background: (Color gray alpha: 0.8) ];
		ticks: 10
]

{ #category : #'example - axis' }
GtRrMachineCountPlot >> axisY [

	^ BrHorizontalPane new
		hFitContent;
		vMatchParent;
		clipChildren: false;
		addChildren: { 
			self axisYName.
			self axisYLabels.
			self axisYTicks width: 10. }
]

{ #category : #accessing }
GtRrMachineCountPlot >> axisYkey [
	^'Number of Worker Machines'
]

{ #category : #'example - axis' }
GtRrMachineCountPlot >> axisYLabels [

	^ GtPlotterVerticalTickLabelsElement new
		scale: self scaleY;
		inverse;
		labelFormat: [ :aValue | 
			(aValue printShowingDecimalPlaces: 0) asRopedText foreground: Color darkGray ];
		labelStyle: [ :anElement |
			(anElement background: Color white)
				constraintsDo: [ :c |
					c frame horizontal alignRight.
					c horizontal fitContent.
					c vertical fitContent ] ];
		constraintsDo: [ :c | 
			c horizontal fitContent.
			c padding: (BlInsets left: 10 right: 10) ];
		clipChildren: false;
		labels: 7
]

{ #category : #'example - axis' }
GtRrMachineCountPlot >> axisYLine [
	
	^ BlElement new
		width: 2;
		background: (Color veryVeryLightGray);
		constraintsDo: [ :c | 
			c vertical matchParent.
			c frame horizontal alignLeft ]
]

{ #category : #'example - axis' }
GtRrMachineCountPlot >> axisYName [

	^(BrFrame new)
		fitContent;
		background: BlBackground transparent;
		constraintsDo: [:c | c linear vertical alignTop];
		addChild: ((BrLabel new)
					aptitude: ((BrGlamorousLabelAptitude new)
								glamorousRegularFont;
								foreground: Color darkGray;
								fontSize: 16);
					text: self axisYkey;
					constraintsDo: 
							[:c |
							c linear vertical alignCenter.
							c accountTransformation];
					transformDo: [:t | t rotateBy: 270])
]

{ #category : #'example - axis' }
GtRrMachineCountPlot >> axisYTicks [
	
	^ GtPlotterVerticalTicksElement new
		scale: self scaleY;
		tickStyle: [ :anElement | anElement
			height: 2;
			background: (Color gray alpha: 0.8) ];
		ticks: 7
]

{ #category : #accessing }
GtRrMachineCountPlot >> content [
	| seconds |

	seconds := values collect: [ :assoc |
		assoc value -> (assoc key - minX) asSeconds ].
	^ (GtHorizontalSparklineStencil new values: seconds) asElement
]

{ #category : #'example - plot' }
GtRrMachineCountPlot >> corner [

	^ BlElement new
		size: 0@0;
		visibility: BlVisibility hidden
]

{ #category : #'example - plot' }
GtRrMachineCountPlot >> plot [

	^ BrHorizontalGrid new
		cellSpacing: 0;
		columnCount: 2;
		matchParent;
		padding: (BlInsets all: 15);
		addChildren: { 
			self corner.
			self axisXProjectionLabels.
			self axisY.
			self content.
			self corner.
			self axisX.
		 }
]

{ #category : #'example - scale' }
GtRrMachineCountPlot >> scaleX [

	^ GtPlotterTimeScale new
		domainFrom: minX
		to: maxX.
]

{ #category : #'example - scale' }
GtRrMachineCountPlot >> scaleY [

	^ GtPlotterLinearScale new 
		domainFrom: minY
		to: maxY.
]

{ #category : #accessing }
GtRrMachineCountPlot >> values [
	^ values
]

{ #category : #accessing }
GtRrMachineCountPlot >> values: aCollection [
	| counts |

	values := aCollection.
	counts := aCollection collect: #value.
	minY := counts min.
	maxY := counts max.
	minX := aCollection first key.
	maxX := aCollection last key.
]
