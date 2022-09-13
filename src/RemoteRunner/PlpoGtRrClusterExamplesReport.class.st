Class {
	#name : #PlpoGtRrClusterExamplesReport,
	#superclass : #PharoLinkProxyObject,
	#category : #'RemoteRunner-Reports'
}

{ #category : #accessing }
PlpoGtRrClusterExamplesReport class >> remoteClassName [
	^ #GtRrClusterExamplesReport
]

{ #category : #'gt - extensions' }
PlpoGtRrClusterExamplesReport >> gtViewExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Execution Timeline';
		priority: 30;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				executions: self machinesExecutionChartItems;
				rowLabelComputation: [ :anItem | anItem label ] ]
]

{ #category : #accessing }
PlpoGtRrClusterExamplesReport >> machinesExecutionChartItems [
	^ self machinesExecutionChartItemsData collect: [ :aDictionary |
		GtRrExecutionChartDataItem fromDictionary: aDictionary]
]

{ #category : #accessing }
PlpoGtRrClusterExamplesReport >> machinesExecutionChartItemsData [
	^ (self proxyPerform: #machinesExecutionChartItemsData) getSerialized
]
