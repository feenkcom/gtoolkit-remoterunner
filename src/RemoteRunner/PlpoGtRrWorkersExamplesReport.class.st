Class {
	#name : #PlpoGtRrWorkersExamplesReport,
	#superclass : #PharoLinkProxyObject,
	#category : #'RemoteRunner-Reports'
}

{ #category : #accessing }
PlpoGtRrWorkersExamplesReport class >> remoteClassName [
	^ #GtRrWorkersExamplesReport
]

{ #category : #'gt - extensions' }
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

{ #category : #'gt - extensions' }
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

{ #category : #'gt - extensions' }
PlpoGtRrWorkersExamplesReport >> gtViewExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Execution Timeline';
		priority: 25;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				executions: self workersExecutionChartItems;
				rowLabelComputation: [ :anItem | anItem label ];
				selectionTransformation: [ :anItem |
					self workerWithId:  anItem identifier ] ]
]

{ #category : #'gt - extensions' }
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
				enabledGroupsInRow;
				selectionTransformation: [ :anItem |
					self workerWithId:  anItem identifier ] ]
]

{ #category : #accessing }
PlpoGtRrWorkersExamplesReport >> workerWithId: aWorkerId [
	^ self 
		proxyPerform:  #workerWithId: 
		withPrimitiveArguments: {aWorkerId} 
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
