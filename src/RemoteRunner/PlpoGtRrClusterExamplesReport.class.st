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
PlpoGtRrClusterExamplesReport >> gtViewCondensedExecutionTimelineFor:aView [
	<gtView>
	
	^ aView forward
		title: 'Condensed Execution Timeline';
		priority: 35;
		object: [ self workersReport];
		view: #gtViewCondensedExecutionTimelineFor:
]

{ #category : #'gt - extensions' }
PlpoGtRrClusterExamplesReport >> gtViewCondensedTasksTimelineFor:  aView [
	<gtView>
	
	^ aView forward
		title: 'Condensed Tasks Timeline';
		priority: 45;
		object: [ self workersReport];
		view: #gtViewCondensedTasksTimelineFor: 
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
				rowLabelComputation: [ :anItem | anItem label ];
				selectionTransformation: [ :anItem |
					self machineWithIpAddress:  anItem identifier ] ]
]

{ #category : #accessing }
PlpoGtRrClusterExamplesReport >> machineWithIpAddress: anIpAddress [ 
	^ self 
		proxyPerform:  #machineWithIpAddress: 
		withPrimitiveArguments: {anIpAddress}
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

{ #category : #accessing }
PlpoGtRrClusterExamplesReport >> workersReport [
	^ self proxyPerform: #workersReport
]
