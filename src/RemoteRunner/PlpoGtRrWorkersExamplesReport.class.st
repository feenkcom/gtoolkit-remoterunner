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
PlpoGtRrWorkersExamplesReport >> workersExecutionChartItems [
	^ self workersExecutionChartItemsData collect: [ :aDictionary |
		GtRrExecutionChartDataItem fromDictionary: aDictionary]
]

{ #category : #accessing }
PlpoGtRrWorkersExamplesReport >> workersExecutionChartItemsData [
	^ (self proxyPerform: #workersExecutionChartItemsData) getSerialized
]
