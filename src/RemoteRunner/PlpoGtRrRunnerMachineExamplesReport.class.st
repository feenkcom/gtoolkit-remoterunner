Class {
	#name : #PlpoGtRrRunnerMachineExamplesReport,
	#superclass : #PharoLinkProxyObject,
	#category : #'RemoteRunner-Reports'
}

{ #category : #accessing }
PlpoGtRrRunnerMachineExamplesReport class >> remoteClassName [
	^ #GtRrRunnerMachineExamplesReport
]

{ #category : #'gt - extensions' }
PlpoGtRrRunnerMachineExamplesReport >> gtViewExecutionTimelineListFor: aView [
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
PlpoGtRrRunnerMachineExamplesReport >> workersExecutionChartItems [
	^ self workersExecutionChartItemsData collect: [ :aDictionary |
		GtRrExecutionChartDataItem fromDictionary: aDictionary]
]

{ #category : #accessing }
PlpoGtRrRunnerMachineExamplesReport >> workersExecutionChartItemsData [
	^ (self proxyPerform: #workersExecutionChartItemsData) getSerialized
]