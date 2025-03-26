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
	"Queue priorities aren't yet implemented, just add to the end of the queue"

	self addTaskContext: taskContext
]

{ #category : #initialization }
GtRemoteRunnerMq >> defaultManagerStartupAndShutdown [
	^ GtRrCodeSyncedLocalManagerStartupAndShutdown new
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
