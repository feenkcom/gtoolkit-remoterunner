"
Tasks can fail for multiple reasons:

- VM failure
- Network failure
- Machine shutdown, e.g. in the case of cloud services
- Flaky tests

To handle these cases a task can specify conditions under which it will be re-run, or an alternate set of tasks will be run.

The alternate set of tasks is useful for example when a task contains multiple tests to be executed.  In this case we want the task to be broken out in to a single test per task, allowing the problem test to be isolated and all the remaining tests to pass.

On task failure, the {{gtClass:GtRemoteRunner}} will call {{gtMethod:GtRrTaskContext>>#retryTasks}} to get the set of tasks to retry, or an empty collection if the task should just fail.
"
Class {
	#name : #GtRrTaskRetry,
	#superclass : #Object,
	#instVars : [
		'failedTask'
	],
	#category : #'RemoteRunner-TaskRetry'
}

{ #category : #accessing }
GtRrTaskRetry >> failedTask [

	^ failedTask
]

{ #category : #accessing }
GtRrTaskRetry >> failedTask: anObject [

	failedTask := anObject
]

{ #category : #accessing }
GtRrTaskRetry >> includesTaskId: aTaskId [
	"Answer a boolean indicating if the supplied task id is the receiver's or one of its retried tasks"

	^ failedTask isNotNil and: [ failedTask includesTaskId: aTaskId ]
]

{ #category : #private }
GtRrTaskRetry >> privateRetryTaskFor: aGtRrTask [
	"Answer a copy of the supplied task"
	| retryTask |

	retryTask := aGtRrTask copy.
	retryTask retryStrategy failedTask: aGtRrTask.
	retryTask executionData
 		additionalDataAt: #failedTaskExecutionData
 			put: aGtRrTask executionData;
 		additionalDataAt: #failedTaskId
 			put: aGtRrTask taskId.
	^ retryTask
]

{ #category : #accessing }
GtRrTaskRetry >> retryTasks: aGtRrTask context: aGtRrTaskContext [
	"Answer the collection of tasks to be retried.
	If no further action should be taken, i.e. the task has passed or should just fail, answer an empty collection.
	Note that the task is asked for retry tasks on both success and failure
	(which allows for the task to handle the scenario where the overall task completed,
	but some subset of the task should be rerun for whatever reason, e.g. and individual
	test failed within the group)."

	^ self subclassResponsibility.
]
