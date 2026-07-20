"
Indicate that the receiver's task should never be retried and just fail.
"
Class {
	#name : #GtRrTaskNeverRetry,
	#superclass : #GtRrTaskRetry,
	#traits : 'TGtUniqueInstance',
	#classTraits : 'TGtUniqueInstance classTrait',
	#category : #'RemoteRunner-TaskRetry'
}

{ #category : #accessing }
GtRrTaskNeverRetry class >> leJsonV4Name [

	^ #gtRrTaskNeverRetry
]

{ #category : #accessing }
GtRrTaskNeverRetry >> retryCount [

	^ 0
]

{ #category : #accessing }
GtRrTaskNeverRetry >> retryTasks: aGtRrTask context: aGtRrContext [
	"Answer the collection of tasks to be retried, in this case none."

	^ #()
]
