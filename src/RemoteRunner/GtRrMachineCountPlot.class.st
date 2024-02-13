Class {
	#name : #GtRrMachineCountPlot,
	#superclass : #GtPlotterRawLineExamples,
	#instVars : [
		'values',
		'minX',
		'maxX',
		'minY',
		'maxY'
	],
	#category : #'RemoteRunner-Analysis'
}

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

{ #category : #accessing }
GtRrMachineCountPlot >> axisXProjectionLabels [

	^ self corner
]

{ #category : #accessing }
GtRrMachineCountPlot >> axisYkey [
	^'Number of Worker Machines'
]

{ #category : #accessing }
GtRrMachineCountPlot >> content [
	| seconds |

	seconds := values collect: [ :assoc |
		assoc value -> (assoc key - minX) asSeconds ].
	^ (GtHorizontalSparklineStencil new values: seconds) asElement
]

{ #category : #accessing }
GtRrMachineCountPlot >> scaleX [

	^ GtPlotterTimeScale new
		domainFrom: minX
		to: maxX.
]

{ #category : #accessing }
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
