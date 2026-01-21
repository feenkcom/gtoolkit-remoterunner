Class {
	#name : #GtRrWorkerHeatbeatMessage,
	#superclass : #GtRrWorkerMessage,
	#category : #'RemoteRunner-Model'
}

{ #category : #processing }
GtRrWorkerHeatbeatMessage >> processMq: mqMessage processor: aGtRrProcessor for: aGtRrMqServer [

	^ aGtRrMqServer remoteRunner heartbeatForWorkerId: workerId.
]
