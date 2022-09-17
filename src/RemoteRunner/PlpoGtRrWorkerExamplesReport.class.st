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
			GtRrTasksExecutionHorizontalChartStencil new 
				taskItems: self tasksExecutionChartItems ]
]

{ #category : #'gt - extensions' }
PlpoGtRrWorkerExamplesReport >> gtViewDurationSortedChartListFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Duration Chart (sorted)';
		priority: 10;
		stencil: [
			GtRrTasksExecutionHorizontalChartStencil new 
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
				executions: self tasksExecutionChartItems;
				selectionTransformation: [ :anItem |
					self taskWithId:  anItem identifier ] ]
]

{ #category : #'gt - extensions' }
PlpoGtRrWorkerExamplesReport >> gtViewExecutionTimelineWithSchedulingFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Execution Timeline (with scheduling)';
		priority: 45;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				withColorBasedOnScheduling;
				executions: self tasksExecutionChartItemsGroupWithScheduling;
				selectionTransformation: [ :anItem |
					self taskWithId:  anItem identifier ] ]
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
