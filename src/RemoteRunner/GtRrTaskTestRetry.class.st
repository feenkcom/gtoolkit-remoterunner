"
GtRrTaskTestRetry is similar to {{gtClass:GtRrTaskFixedRetry}} in that the number of retries is specified, but tasks are split out so that each task contains only a single test, preventing one test from interfering with another test.
"
Class {
	#name : #GtRrTaskTestRetry,
	#superclass : #GtRrTaskRetry,
	#instVars : [
		'maxRetries',
		'retryCount'
	],
	#category : #'RemoteRunner-TaskRetry'
}

{ #category : #accessing }
GtRrTaskTestRetry class >> leJsonV4Name [

	^ #gtRrTaskTestRetry
]

{ #category : #accessing }
GtRrTaskTestRetry >> initialize [

	super initialize.
	retryCount := 0.
	maxRetries := 2.
]

{ #category : #accessing }
GtRrTaskTestRetry >> maxRetries [

	^ maxRetries
]

{ #category : #accessing }
GtRrTaskTestRetry >> maxRetries: anObject [

	maxRetries := anObject
]

{ #category : #accessing }
GtRrTaskTestRetry >> retryCount [

	^ retryCount
]

{ #category : #accessing }
GtRrTaskTestRetry >> retryCount: anObject [

	retryCount := anObject
]

{ #category : #accessing }
GtRrTaskTestRetry >> retryTasks: aGtRrTask context: aGtRrTaskContext [
	"Test retry has a maximum number of retries, however if the task contains multiple tests we want to break out the tests in to individual tasks so that one test can't cause the failure of others"
	| retryTasks |

	(aGtRrTask hasErrors not and:
		[ aGtRrTask totalCount - aGtRrTask numberOfSuccesses = 0 ]) ifTrue: [ ^ #() ].
	retryCount := retryCount + 1.
	^ retryCount <= maxRetries ifTrue: 
		[ retryTasks := aGtRrTask splitTestsIn: aGtRrTaskContext.
		retryTasks do: [ :retryTask |
			retryTask retryStrategy failedTask: aGtRrTask.
			retryTask executionData
				additionalDataAt: #failedTaskExecutionData
					put: aGtRrTask executionData;
				additionalDataAt: #failedTaskId
					put: aGtRrTask taskId ].
			retryTasks ]
	ifFalse:
		[ #() ].
]
