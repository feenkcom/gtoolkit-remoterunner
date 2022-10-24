"
Retry the receiver's task a fixed number of times and then fail if still not successful.
"
Class {
	#name : #GtRrTaskFixedRetry,
	#superclass : #GtRrTaskRetry,
	#instVars : [
		'maxRetries',
		'retryCount'
	],
	#category : #'RemoteRunner-TaskRetry'
}

{ #category : #accessing }
GtRrTaskFixedRetry class >> leJsonV4Name [

	^ #gtRrTaskFixedRetry
]

{ #category : #accessing }
GtRrTaskFixedRetry >> initialize [

	super initialize.
	retryCount := 0.
	maxRetries := 3.
]

{ #category : #accessing }
GtRrTaskFixedRetry >> maxRetries [

	^ maxRetries
]

{ #category : #accessing }
GtRrTaskFixedRetry >> maxRetries: anObject [

	maxRetries := anObject
]

{ #category : #accessing }
GtRrTaskFixedRetry >> retryCount [

	^ retryCount
]

{ #category : #accessing }
GtRrTaskFixedRetry >> retryCount: anObject [

	retryCount := anObject
]

{ #category : #accessing }
GtRrTaskFixedRetry >> retryTask: aGtRrTask [
	"Answer the collection of tasks to be retried.
	If the task should just fail answer an empty collection."

	retryCount := retryCount + 1.
	^ retryCount <= maxRetries 
		ifTrue: [ { self privateRetryTaskFor: aGtRrTask } ]
		ifFalse: [ #() ].
]
