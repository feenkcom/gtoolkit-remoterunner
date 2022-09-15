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
				rowLabelComputation: [ :anItem | anItem label ]]
]

{ #category : #'gt - extensions' }
PlpoGtRrWorkerExamplesReport >> gtViewExecutionTimelineWithSchedulingFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Execution Timeline (with scheduling)';
		priority: 45;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				executions: self tasksExecutionChartItemsGroupWithScheduling;
				rowLabelComputation: [ :anItem | anItem label ];
				colorComputation: [ :anItem |
					(anItem propertyAt: #correctScheduling ifAbsent: [ false ])
						ifFalse: [ Color red ] 
						ifTrue: [ Color gray ] ]]
]

{ #category : #accessing }
PlpoGtRrWorkerExamplesReport >> tasksExecutionChartItems [
	^ self tasksExecutionChartItemsData collect: [ :aDictionary |
		GtRrExecutionChartDataItem fromDictionary: aDictionary]
]

{ #category : #accessing }
PlpoGtRrWorkerExamplesReport >> tasksExecutionChartItemsData [
	^ (self proxyPerform: #tasksExecutionChartItemsData) getSerialized
]

{ #category : #accessing }
PlpoGtRrWorkerExamplesReport >> tasksExecutionChartItemsGroupWithScheduling [
	^  GtRrExecutionChartDataItemsGroup 
		fromDictionary: self tasksExecutionChartItemsGroupWithSchedulingData
]

{ #category : #accessing }
PlpoGtRrWorkerExamplesReport >> tasksExecutionChartItemsGroupWithSchedulingData [
	^ (self proxyPerform: #tasksExecutionChartItemsGroupWithSchedulingData) getSerialized
]
