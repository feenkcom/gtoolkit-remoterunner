"
{{gtClass:GtRrWorkerSingleConnectionStrategy}} creates and uses a single connection to the RemoteRunner, i.e. it implements the original strategy of {{gtClass:GtRrWorker}}.

No attempt to reconnect is made if the connection is lost.
"
Class {
	#name : #GtRrWorkerSingleConnectionStrategy,
	#superclass : #GtRrWorkerConnectionStrategy,
	#instVars : [
		'application'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #naming }
GtRrWorkerSingleConnectionStrategy class >> strategyName [

	^ #singleConnectionStrategy
]

{ #category : #'api - running' }
GtRrWorkerSingleConnectionStrategy >> connectDuring: aBlock [
	"Evaluate aBlock passing in a connected PharoLinkApplication"

	^ aBlock value: application.
]

{ #category : #'start-stop' }
GtRrWorkerSingleConnectionStrategy >> start [

	application := self newApplication start.
	worker registerWith: application.
	worker addObserver.
]

{ #category : #'start-stop' }
GtRrWorkerSingleConnectionStrategy >> stop [

	worker unregisterWith: application.
	application stop.
]
