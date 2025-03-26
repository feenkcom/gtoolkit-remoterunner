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

{ #category : #'accessing - chart data' }
PlpoGtRrClusterExamplesReport >> machinesExecutionChartItems [
	^ self proxyPerformSerialized: #machinesExecutionChartItems
]

{ #category : #accessing }
PlpoGtRrClusterExamplesReport >> machineWithIpAddress: anIpAddress [ 
	^ self 
		proxyPerform:  #machineWithIpAddress: 
		withPrimitiveArguments: {anIpAddress}
]

{ #category : #accessing }
PlpoGtRrClusterExamplesReport >> workersReport [
	^ self proxyPerform: #workersReport
]
