Class {
	#name : #GtRrTasksGroup,
	#superclass : #Object,
	#traits : 'TGtGroupWithItems',
	#classTraits : 'TGtGroupWithItems classTrait',
	#category : 'RemoteRunner-Tasks'
}

{ #category : #'math functions' }
GtRrTasksGroup >> count: aBlock [
	^ self items count: aBlock
]

{ #category : #accessing }
GtRrTasksGroup >> duration [
	^ self items  
		inject: 0 seconds 
		into: [ :totalDuration :aTask |
			aTask duration 
				ifNil: [ totalDuration ]
				ifNotNil: [ :aDuration | totalDuration + aDuration ] ]
]

{ #category : #accessing }
GtRrTasksGroup >> durationOnRunner [
	^ self items  
		inject: 0 seconds 
		into: [ :totalDuration :aTask |
			aTask durationOnRunner 
				ifNil: [ totalDuration ]
				ifNotNil: [ :aDuration | totalDuration + aDuration ] ]
]

{ #category : #accessing }
GtRrTasksGroup >> durationOnWorker [
	^ self items  
		inject: 0 seconds 
		into: [ :totalDuration :aTask |
			aTask durationOnWorker 
				ifNil: [ totalDuration ]
				ifNotNil: [ :aDuration | totalDuration + aDuration ] ]
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

{ #category : #accessing }
GtRrTasksGroup >> firstHandoverTime [ 
	^ self firstTask handoverTime
]

{ #category : #accessing }
GtRrTasksGroup >> firstTask [ 
	| firstTask |
	firstTask := self items first.
	self do: [ :aTask | 
		(aTask handoverTime notNil and: [ aTask handoverTime < firstTask handoverTime ])
			ifTrue: [
				firstTask := aTask ] ].
	^ firstTask
]

{ #category : #accessing }
GtRrTasksGroup >> firstTaskWithResourceReport [ 
	| lastTask |
	lastTask := nil .
	self do: [ :aTask | 
		aTask executionData resourceReport ifNotNil: [
			lastTask ifNil: [ 
				lastTask := aTask ].
			(aTask handoverTime notNil and: [ 
				aTask handoverTime < lastTask handoverTime ])
					ifTrue: [
						lastTask := aTask ] ] ].
	^ lastTask
]

{ #category : #accessing }
GtRrTasksGroup >> from: start to: stop do: aBlock [
	^ self items from: start to: stop do: aBlock
]

{ #category : #'accessing - gc details' }
GtRrTasksGroup >> fullGcTime [
	^ self items gtSumWithNilValues: [ :aTask | aTask fullGcTime ] 
]

{ #category : #accessing }
GtRrTasksGroup >> gtMaxWithNilValues:  aBlock [
	^ self items gtMaxWithNilValues: aBlock
]

{ #category : #accessing }
GtRrTasksGroup >> gtMinWithNilValues: aBlock [
	^ self items gtMinWithNilValues: aBlock
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
			GtRrTasksExecutionHorizontalChartStencil new 
				taskItems: ((self select: #isFinished)
					sorted: [ :aTask | aTask duration ] descending) ]
]

{ #category : #'gt - extensions' }
GtRrTasksGroup >> gtViewTimelineV4For: aView [
	<gtView>
	^ aView explicit
		title: 'Timeline (v4)';
		priority: 20; 
		stencil: [
			GtRrTasksExecutionHorizontalChartStencil new 
				taskItems: (self 
					select: #isFinished) ]
]

{ #category : #'accessing - gc details' }
GtRrTasksGroup >> incrGcTime [
	^ self items gtSumWithNilValues: [ :aTask | aTask incrGcTime ] 
]

{ #category : #initialization }
GtRrTasksGroup >> initializeWith: aCollection [
	items := aCollection
]

{ #category : #enumerating }
GtRrTasksGroup >> inject: thisValue into: binaryBlock [ 
	^ self items inject: thisValue into: binaryBlock 
]

{ #category : #accessing }
GtRrTasksGroup >> lastResultReceivedTime [ 
	| time |
	time := self items first resultReceivedTime.
	self do: [ :aTask | 
		(aTask resultReceivedTime notNil and: [ aTask resultReceivedTime > time ])
			ifTrue: [
				time := aTask resultReceivedTime ] ].
	^ time
]

{ #category : #accessing }
GtRrTasksGroup >> lastTask [ 
	| lastTask |
	lastTask := self items first.
	self do: [ :aTask | 
		(aTask resultReceivedTime notNil and: [ 
			aTask resultReceivedTime > lastTask resultReceivedTime ])
				ifTrue: [
					lastTask := aTask ] ].
	^ lastTask
]

{ #category : #accessing }
GtRrTasksGroup >> lastTaskWithResourceReport [ 
	| lastTask |
	lastTask := nil .
	self do: [ :aTask | 
		aTask executionData resourceReport ifNotNil: [
			lastTask ifNil: [ 
				lastTask := aTask ].
			(aTask resultReceivedTime notNil and: [ 
				aTask resultReceivedTime > lastTask resultReceivedTime ])
					ifTrue: [
						lastTask := aTask ] ] ].
	^ lastTask
]

{ #category : #accessing }
GtRrTasksGroup >> maxValue: aBlock [
	^ self items maxValue: aBlock
]

{ #category : #accessing }
GtRrTasksGroup >> overlappingPairsDo:  aBlockClosure [
	^ self items overlappingPairsDo: aBlockClosure
]

{ #category : #accessing }
GtRrTasksGroup >> pairsDo: aBlock [
	^ self items  pairsDo: aBlock
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

{ #category : #'math functions' }
GtRrTasksGroup >> sumNumbers: aBlock [
	^ self items sumNumbers: aBlock
]

{ #category : #'accessing - gc details' }
GtRrTasksGroup >> totalGCTime [ 
	^ self items gtSumWithNilValues: [ :aTask | aTask totalGCTime ] 
]

{ #category : #'accessing - resource report' }
GtRrTasksGroup >> vmMaximumMemorySize [
	^ self items gtMaxWithNilValues: [ :aTask | aTask vmMaximumMemorySize ]
]

{ #category : #'accessing - resource report' }
GtRrTasksGroup >> vmMinimumMemorySize [
	^ self items gtMaxWithNilValues: [ :aTask | aTask vmMinimumMemorySize ]
]

{ #category : #'accessing - resource report' }
GtRrTasksGroup >> vmStatisticsAtCompletion [
	^ self lastTaskWithResourceReport 
		ifNotNil: [ :aTask | aTask vmStatisticsAtCompletion ]
]

{ #category : #'accessing - resource report' }
GtRrTasksGroup >> vmStatisticsAtStart [
	^ self firstTask 
		ifNotNil: [ :aTask | aTask vmStatisticsAtStart ]
]
