Class {
	#name : #PlpoGtRrWorkersExamplesReport,
	#superclass : #PharoLinkProxyObject,
	#category : #'RemoteRunner-Reports'
}

{ #category : #accessing }
PlpoGtRrWorkersExamplesReport class >> remoteClassName [
	^ #GtRrWorkersExamplesReport
]

{ #category : #accessing }
PlpoGtRrWorkersExamplesReport >> gtViewCondensedExecutionTimelineFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Condensed Execution Timeline';
		priority: 35;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				executions: self workersExecutionChartItems;
				rowLabelComputation: [ :anItem | anItem label ];
				colorComputation: [ Color darkGray ];
				configureWithMinimalDetails ]
]

{ #category : #accessing }
PlpoGtRrWorkersExamplesReport >> gtViewCondensedTasksTimelineFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Condensed Tasks Timeline';
		priority: 45;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				executions: self workersTasksExecutionChartItemsGroupWithScheduling;
				rowLabelComputation: [ :anItem | anItem label ];
				colorComputation: [ :anItem |
					(anItem propertyAt: #correctScheduling ifAbsent: [ false ])
						ifFalse: [ Color red ] 
						ifTrue: [ Color gray ] ];
				enabledGroupsInRow;
				configureWithMinimalDetails ]
]

{ #category : #accessing }
PlpoGtRrWorkersExamplesReport >> gtViewExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Execution Timeline';
		priority: 25;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				executions: self workersExecutionChartItems;
				rowLabelComputation: [ :anItem | anItem label ] ]
]

{ #category : #accessing }
PlpoGtRrWorkersExamplesReport >> gtViewTasksExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Tasks Timeline';
		priority: 20;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				executions: self workersTasksExecutionChartItemsGroupWithScheduling;
				rowLabelComputation: [ :anItem | anItem label ];
				colorComputation: [ :anItem |
					(anItem propertyAt: #correctScheduling ifAbsent: [ false ])
						ifFalse: [ Color red ] 
						ifTrue: [ Color gray ] ];
				enabledGroupsInRow ]
]

{ #category : #accessing }
PlpoGtRrWorkersExamplesReport >> workersExecutionChartItems [
	^ self workersExecutionChartItemsData collect: [ :aDictionary |
		GtRrExecutionChartDataItem fromDictionary: aDictionary]
]

{ #category : #accessing }
PlpoGtRrWorkersExamplesReport >> workersExecutionChartItemsData [
	^ (self proxyPerform: #workersExecutionChartItemsData) getSerialized
]

{ #category : #accessing }
PlpoGtRrWorkersExamplesReport >> workersTasksExecutionChartItemsData [
	^ (self proxyPerform: #workersTasksExecutionChartItemsData) getSerialized
]

{ #category : #accessing }
PlpoGtRrWorkersExamplesReport >> workersTasksExecutionChartItemsGroup [
	^ self workersTasksExecutionChartItemsData collect: [ :aDictionary |
		GtRrExecutionChartDataItemsGroup fromDictionary: aDictionary]
]

{ #category : #accessing }
PlpoGtRrWorkersExamplesReport >> workersTasksExecutionChartItemsGroupWithScheduling [
	^ self workersTasksExecutionChartItemsGroupWithSchedulingData collect: [ :aDictionary |
		GtRrExecutionChartDataItemsGroup fromDictionary: aDictionary]
]

{ #category : #accessing }
PlpoGtRrWorkersExamplesReport >> workersTasksExecutionChartItemsGroupWithSchedulingData [
	^ (self proxyPerform: #workersTasksExecutionChartItemsGroupWithSchedulingData) getSerialized
]
