Class {
	#name : #PlpoGtRrWorkersExamplesReport,
	#superclass : #PharoLinkProxyObject,
	#traits : 'TGtRrWorkersExamplesReportViews',
	#classTraits : 'TGtRrWorkersExamplesReportViews classTrait',
	#category : #'RemoteRunner-Reports'
}

{ #category : #accessing }
PlpoGtRrWorkersExamplesReport class >> remoteClassName [
	^ #GtRrWorkersExamplesReport
]

{ #category : #accessing }
PlpoGtRrWorkersExamplesReport >> workerWithId: aWorkerId [
	^ self 
		proxyPerform:  #workerWithId: 
		withPrimitiveArguments: {aWorkerId} 
]

{ #category : #'accessing - chart data' }
PlpoGtRrWorkersExamplesReport >> workersExecutionChartItems [
	^ self proxyPerformSerialized: #workersExecutionChartItems
]

{ #category : #'accessing - chart data' }
PlpoGtRrWorkersExamplesReport >> workersTasksExecutionChartItemsGroupWithSchedulingAndRunnerTimes [
	^ self 
		proxyPerformSerialized: #workersTasksExecutionChartItemsGroupWithSchedulingAndRunnerTimes
]

{ #category : #'accessing - chart data' }
PlpoGtRrWorkersExamplesReport >> workersTasksExecutionChartItemsGroupWithSchedulingAndWorkerTimes [
	^ self 
		proxyPerformSerialized: #workersTasksExecutionChartItemsGroupWithSchedulingAndWorkerTimes
]

{ #category : #'accessing - chart data' }
PlpoGtRrWorkersExamplesReport >> workersTasksMachineAvailableMemoryChartItems [
	^ self proxyPerformSerialized: #workersTasksMachineAvailableMemoryChartItems
]

{ #category : #'accessing - chart data' }
PlpoGtRrWorkersExamplesReport >> workersTasksMachineFreeMemoryChartItems [
	^ self proxyPerformSerialized: #workersTasksMachineFreeMemoryChartItems
]
