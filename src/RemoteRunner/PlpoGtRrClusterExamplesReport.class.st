Class {
	#name : #PlpoGtRrClusterExamplesReport,
	#superclass : #PharoLinkProxyObject,
	#traits : 'TGtRrClusterExamplesReportViews',
	#classTraits : 'TGtRrClusterExamplesReportViews classTrait',
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
		title: 'Condensed execution timeline';
		priority: 35;
		object: [ self workersReport];
		view: #gtViewCondensedExecutionTimelineFor:
]

{ #category : #'gt - extensions' }
PlpoGtRrClusterExamplesReport >> gtViewCondensedTasksTimelineFor:  aView [
	<gtView>
	
	^ aView forward
		title: 'Condensed tasks timeline';
		priority: 45;
		object: [ self workersReport];
		view: #gtViewCondensedTasksTimelineFor: 
]

{ #category : #'gt - extensions' }
PlpoGtRrClusterExamplesReport >> gtViewExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Execution timeline';
		priority: 30;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				executions: self machinesExecutionChartItems;
				selectionTransformation: [ :anItem |
					self machineWithIpAddress:  anItem identifier ] ]
]

{ #category : #accessing }
PlpoGtRrClusterExamplesReport >> machineWithIpAddress: anIpAddress [ 
	^ self 
		proxyPerform:  #machineWithIpAddress: 
		withPrimitiveArguments: {anIpAddress}
]

{ #category : #'accessing - chart data' }
PlpoGtRrClusterExamplesReport >> machinesExecutionChartItems [
	^ self proxyPerformSerialized: #machinesExecutionChartItems
]

{ #category : #accessing }
PlpoGtRrClusterExamplesReport >> workersReport [
	^ self proxyPerform: #workersReport
]
