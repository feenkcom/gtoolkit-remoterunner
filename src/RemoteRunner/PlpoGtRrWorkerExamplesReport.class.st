Class {
	#name : #PlpoGtRrWorkerExamplesReport,
	#superclass : #PharoLinkProxyObject,
	#category : #'RemoteRunner-Reports'
}

{ #category : #accessing }
PlpoGtRrWorkerExamplesReport class >> remoteClassName [ 
	^ #GtRrWorkerExamplesReport
]

{ #category : #'gt - extensions' }
PlpoGtRrWorkerExamplesReport >> gtViewDurationExecutionChartListFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Duration Chart';
		priority: 11;
		stencil: [
			GtRrTasksExecutionVerticalChartStencil new 
				taskItems: self tasksExecutionChartItems ]
]

{ #category : #'gt - extensions' }
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

{ #category : #'gt - extensions' }
PlpoGtRrWorkerExamplesReport >> gtViewExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Execution Timeline';
		priority: 25;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				executions: self tasksExecutionChartItems ]
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
