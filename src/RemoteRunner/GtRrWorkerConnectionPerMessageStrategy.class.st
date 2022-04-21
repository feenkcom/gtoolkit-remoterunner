Class {
	#name : #GtRrWorkerConnectionPerMessageStrategy,
	#superclass : #GtRrWorkerConnectionStrategy,
	#category : #'RemoteRunner-Worker'
}

{ #category : #'api - running' }
GtRrWorkerConnectionPerMessageStrategy >> connectDuring: aBlock [
	"Evaluate aBlock passing in a connected PharoLinkApplication"
	| application |

	^ [ application := self newApplication start.
	aBlock value: application ]
		ensure: [ application stop ]
]

{ #category : #accessing }
GtRrWorkerConnectionPerMessageStrategy >> start [ 
	"Start the receiver"

	self connectDuring: [ :application |
		worker registerWith: application ]
]

{ #category : #accessing }
GtRrWorkerConnectionPerMessageStrategy >> stop [ 
	"Stop the receiver.
	As connections are created as-required, no action needed now"

	self connectDuring: [ :application |
		worker unregisterWith: application ]
]
