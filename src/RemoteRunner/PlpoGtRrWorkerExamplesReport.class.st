Class {
	#name : #PlpoGtRrWorkerExamplesReport,
	#superclass : #PharoLinkProxyObject,
	#traits : 'TGtRrWorkerExamplesReportViews',
	#classTraits : 'TGtRrWorkerExamplesReportViews classTrait',
	#category : #'RemoteRunner-Reports'
}

{ #category : #accessing }
PlpoGtRrWorkerExamplesReport class >> remoteClassName [ 
	^ #GtRrWorkerExamplesReport
]

{ #category : #accessing }
PlpoGtRrWorkerExamplesReport >> taskWithId: aTaskId [ 
	^ self 
		proxyPerform:  #taskWithId: 
		withPrimitiveArguments: {aTaskId}
]

{ #category : #'accessing - chart data' }
PlpoGtRrWorkerExamplesReport >> tasksExecutionChartItems [
	^ self proxyPerformSerialized: #tasksExecutionChartItems
]

{ #category : #'accessing - chart data' }
PlpoGtRrWorkerExamplesReport >> tasksExecutionChartItemsGroupWithScheduling [
	^ self proxyPerformSerialized: #tasksExecutionChartItemsGroupWithScheduling
]

{ #category : #'accessing - chart data' }
PlpoGtRrWorkerExamplesReport >> tasksMachineAvailableMemoryChartItems [
	^ self proxyPerformSerialized: #tasksMachineAvailableMemoryChartItems
]

{ #category : #'accessing - chart data' }
PlpoGtRrWorkerExamplesReport >> tasksMachineFreeMemoryChartItems [
	^ self proxyPerformSerialized: #tasksMachineFreeMemoryChartItems
]

{ #category : #'accessing - chart data' }
PlpoGtRrWorkerExamplesReport >> tasksVmMemoryChartItems [
	^ self proxyPerformSerialized: #tasksVmMemoryChartItems
]
