Class {
	#name : #PlpoGtRrWorkerExamplesReport,
	#superclass : #PharoLinkProxyObject,
	#category : #'RemoteRunner-Worker'
}

{ #category : #accessing }
PlpoGtRrWorkerExamplesReport class >> remoteClassName [ 
	^ #GtRrWorkerExamplesReport
]

{ #category : #accessing }
PlpoGtRrWorkerExamplesReport >> gtViewDurationExecutionChartListFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Duration Chart';
		priority: 11;
		stencil: [
			GtRrTasksExecutionVerticalChartStencil new 
				taskItems: self tasksExecutionChartItems ]
]

{ #category : #accessing }
PlpoGtRrWorkerExamplesReport >> gtViewDurationSortedChartListFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Duration Chart (sorted)';
		priority: 10;
		stencil: [
			GtRrTasksExecutionVerticalChartStencil new 
				taskItems: (self tasksExecutionChartItems
					sorted: [ :aTaskItem | aTaskItem duration ] descending) ]
]

{ #category : #accessing }
PlpoGtRrWorkerExamplesReport >> tasksExecutionChartItems [
	^ self tasksExecutionChartItemsData collect: [ :aDictionary |
		GtRrTasksExecutionChartTaskDataModel fromDictionary: aDictionary]
]

{ #category : #accessing }
PlpoGtRrWorkerExamplesReport >> tasksExecutionChartItemsData [
	^ (self proxyPerform: #tasksExecutionChartItemsData) getSerialized
]
