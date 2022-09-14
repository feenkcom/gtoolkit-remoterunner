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
PlpoGtRrWorkersExamplesReport >> gtViewCondensedTasksExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Condensed Tasks Timeline';
		priority: 35;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				executions: self workersTasksExecutionChartItemsGroup;
				rowLabelComputation: [ :anItem | anItem label ];
				colorComputation: [ Color darkGray ];
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
		priority: 25;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				executions: self workersTasksExecutionChartItemsGroup;
				rowLabelComputation: [ :anItem | anItem label ] ]
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
