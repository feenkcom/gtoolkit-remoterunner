Class {
	#name : #GtRemoteRunnerMq,
	#superclass : #GtRemoteRunner,
	#category : #'RemoteRunner-MQ-Runner'
}

{ #category : #adding }
GtRemoteRunnerMq >> addTaskContext: taskContext [
	"Submit the supplied task for processing."

	self critical:
		[ server sendWorkerTaskContext: taskContext asWorkerTaskContext.
		self addCurrentlyExecutingTask: taskContext ]
]

{ #category : #adding }
GtRemoteRunnerMq >> addTaskContextFirst: taskContext [
	"Add the supplied taskContext to the front of the queue."

	self critical:
		[ server sendWorkerTaskContextFirst: taskContext asWorkerTaskContext.
		self addCurrentlyExecutingTask: taskContext ]
]

{ #category : #accessing }
GtRemoteRunnerMq >> defaultConnectionStrategy [

	^ #stompMq
]

{ #category : #initialization }
GtRemoteRunnerMq >> defaultManagerStartupAndShutdown [
	^ GtRrCodeSyncedLocalManagerStartupAndShutdown new
]

{ #category : #'as yet unclassified' }
GtRemoteRunnerMq >> gtResultQueueSummaryFor: aView [
	<gtView>
	^ aView forward
		title: 'Result MQ';
		priority: 54;
		object: [ server mqMonitor ];
		view: #gtResultQueueSummaryFor:
]

{ #category : #'as yet unclassified' }
GtRemoteRunnerMq >> gtRunnerControlSummaryFor: aView [
	<gtView>
	^ aView forward
		title: 'Runner Control MQ';
		priority: 56;
		object: [ server mqMonitor ];
		view: #gtRunnerControlSummaryFor:
]

{ #category : #'as yet unclassified' }
GtRemoteRunnerMq >> gtTaskQueueSummaryFor: aView [
	<gtView>
	^ aView forward
		title: 'Task MQ';
		priority: 52;
		object: [ server mqMonitor ];
		view: #gtTaskQueueSummaryFor:
]

{ #category : #accessing }
GtRemoteRunnerMq >> port: aString [
	"For MessageQueue, this is the address of the MQ server."

	port := aString.

	runnerStats 
		portNumber: port;
		isRunning: self isRunning.
]

{ #category : #private }
GtRemoteRunnerMq >> taskCompletedForWorkerId: workerId [

	(jobStartupAndShutdown finishedWithWorkerId: workerId) ifTrue:
		[ runnerStats updateAvailableWorkerCounts: availableWorkers.
		self stopWorkerId: workerId reason: 'Finished with worker' ].
]

{ #category : #testing }
GtRemoteRunnerMq >> useMessageQueue [

	^ true
]

{ #category : #accessing }
GtRemoteRunnerMq >> workerConnectionStrategyId [
	"Answer the connection strategy to be used.
	Use the default strategy."
	
	^ #stompMq
]
