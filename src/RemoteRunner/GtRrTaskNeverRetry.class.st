"
Indicate that the receiver's task should never be retried and just fail.
"
Class {
	#name : #GtRrTaskNeverRetry,
	#superclass : #GtRrTaskRetry,
	#category : #'RemoteRunner-TaskRetry'
}

{ #category : #accessing }
GtRrTaskNeverRetry >> retryTasks [
	"Answer the collection of tasks to be retried, in this case none."

	^ #()
]
