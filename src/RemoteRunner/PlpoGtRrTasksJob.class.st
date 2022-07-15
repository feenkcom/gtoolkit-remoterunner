Class {
	#name : #PlpoGtRrTasksJob,
	#superclass : #PlpoGtRrJob,
	#instVars : [
		'tasks'
	],
	#category : #'RemoteRunner-Jobs'
}

{ #category : #accessing }
PlpoGtRrTasksJob class >> remoteClassName [

	^ #GtRrTasksJob
]

{ #category : #'accessing - examples' }
PlpoGtRrTasksJob >> allExamples [

	^ self proxyPerform: #allExamples
]

{ #category : #'accessing - examples' }
PlpoGtRrTasksJob >> erroredExamples [

	^ self proxyPerform: #erroredExamples
]

{ #category : #'accessing - examples' }
PlpoGtRrTasksJob >> erroredExamplesCount [

	^ self proxyPerform: #erroredExamplesCount
]

{ #category : #'accessing - examples' }
PlpoGtRrTasksJob >> executedExamplesCount [

	^ self proxyPerform: #executedExamplesCount
]

{ #category : #'accessing - examples' }
PlpoGtRrTasksJob >> failedExamples [

	^ self proxyPerform: #failedExamples
]

{ #category : #'accessing - examples' }
PlpoGtRrTasksJob >> failedExamplesCount [

	^ self proxyPerform: #failedExamplesCount
]

{ #category : #ui }
PlpoGtRrTasksJob >> gtViewTestsActionFor: anAction [
	<gtAction>

	self hasTests ifFalse: [ ^ anAction noAction ].

	^ anAction button
		tooltip: 'View Test Results';
		icon: BrGlamorousVectorIcons signal;
		action: [ :button | button phlow spawnObject:
			(GtRrExamplesView new job: self "getSerialized") ].
]

{ #category : #testing }
PlpoGtRrTasksJob >> hasTests [

	^ self proxyPerform: #hasTests
]

{ #category : #'accessing - examples' }
PlpoGtRrTasksJob >> notExecutedExamples [

	^ self proxyPerform: #notExecutedExamples
]

{ #category : #'accessing - examples' }
PlpoGtRrTasksJob >> skippedExamples [

	^ self proxyPerform: #skippedExamples
]

{ #category : #'accessing - examples' }
PlpoGtRrTasksJob >> successfulExamples [

	^ self proxyPerform: #successfulExamples
]

{ #category : #'accessing - examples' }
PlpoGtRrTasksJob >> successfulExamplesCount [

	^ self proxyPerform: #successfulExamplesCount
]

{ #category : #accessing }
PlpoGtRrTasksJob >> tasks [

	^ self newCommandFactory 
		<< 'tasks asArray';
		sendAndWait.
]

{ #category : #'accessing - examples' }
PlpoGtRrTasksJob >> totalExamplesCount [

	^ self proxyPerform: #totalExamplesCount
]
