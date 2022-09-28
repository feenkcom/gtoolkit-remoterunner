Class {
	#name : #GtRrWorkerInImageConnectionStrategy,
	#superclass : #GtRrWorkerConnectionStrategy,
	#category : #'RemoteRunner-Worker'
}

{ #category : #naming }
GtRrWorkerInImageConnectionStrategy class >> strategyName [

	^ #inImageConnectionStrategy
]

{ #category : #'api - running' }
GtRrWorkerInImageConnectionStrategy >> connectDuring: aBlock [
	"Evaluate aBlock passing in self as the PharoLinkApplication"

	^ aBlock value: self.
]

{ #category : #'start-stop' }
GtRrWorkerInImageConnectionStrategy >> start [

	worker isRunning ifTrue: [ ^ self error: 'Worker already started' ].
	self assert: worker remoteRunner isNotNil
		description: 'The worker''s remote runner must be set before starting'.
	worker registerWith: self.

]

{ #category : #'start-stop' }
GtRrWorkerInImageConnectionStrategy >> stop [

	worker unregisterWith: self.

]
