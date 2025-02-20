Class {
	#name : #GtRrMqServerManager,
	#superclass : #GtRrServerManager,
	#instVars : [
		'mqServer'
	],
	#category : #'RemoteRunner-Runner-Manager'
}

{ #category : #'api - worker' }
GtRrMqServerManager >> registerWorker: aWorkerConnection [
	"Do nothing"
]

{ #category : #'as yet unclassified' }
GtRrMqServerManager >> shutdown [

	mqServer stop.
]

{ #category : #'as yet unclassified' }
GtRrMqServerManager >> startup [

	mqServer := GtRrMqServer new
		remoteRunner: remoteRunner.
	remoteRunner server: mqServer.
	mqServer start.
]
