Class {
	#name : #PlpoGtRrTasksJob,
	#superclass : #PlpoGtRrJob,
	#instVars : [
		'tasks'
	],
	#category : 'RemoteRunner-Jobs'
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

{ #category : #'accessing - reports' }
PlpoGtRrTasksJob >> examplesReport [
	^ self proxyPerform: #examplesReport
]

{ #category : #'accessing - examples' }
PlpoGtRrTasksJob >> failedExamples [

	^ self proxyPerform: #failedExamples
]

{ #category : #ui }
PlpoGtRrTasksJob >> gtViewTestsActionFor: anAction [
	<gtAction>

	(application isRunning and: [ self hasTests ]) ifFalse: 
		[ ^ anAction noAction ].

	^ anAction button
		tooltip: 'View Test Results';
		icon: BrGlamorousVectorIcons eg;
		action: [ :button | button phlow spawnObject:
			self examplesReport ].
]

{ #category : #ui }
PlpoGtRrTasksJob >> gtViewWorkersReportActionFor: anAction [
	<gtAction>

	^ anAction button
		tooltip: 'View Workers Report';
		icon: BrGlamorousVectorIcons changes;
		action: [ :button | button phlow spawnObject:
			self workersReport ].
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
PlpoGtRrTasksJob >> numberOfErroredExamples [

	^ self proxyPerform: #numberOfErroredExamples
]

{ #category : #'accessing - examples' }
PlpoGtRrTasksJob >> numberOfFailedExamples [

	^ self proxyPerform: #numberOfFailedExamples
]

{ #category : #'accessing - examples' }
PlpoGtRrTasksJob >> numberOfSkippedExamples [

	^ self proxyPerform: #numberOfSkippedExamples
]

{ #category : #'accessing - examples' }
PlpoGtRrTasksJob >> numberOfSuccessfulExamples [

	^ self proxyPerform: #numberOfSuccessfulExamples
]

{ #category : #notifications }
PlpoGtRrTasksJob >> showExamplesProgressNotification [
	"Open a global notification showing the progress of the receiver assuming all tasks are exemples / test related.
	This method is explicitly added to the proxy object, so that the notification will open on the actual proxy."

	^ GtRrExamplesProgressNotification job: self.
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
PlpoGtRrTasksJob >> totalExamplesCount [

	^ self proxyPerform: #totalExamplesCount
]

{ #category : #'accessing - reports' }
PlpoGtRrTasksJob >> workersReport [
	^ self proxyPerform: #workersReport
]
