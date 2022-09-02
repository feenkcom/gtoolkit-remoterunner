"
Tasks can fail for multiple reasons:

- VM failure
- Network failure
- Machine shutdown, e.g. in the case of cloud services
- Flaky tests

To handle these cases a task can specify conditions under which it will be re-run, or an alternate set of tasks will be run.

The alternate set of tasks is useful for example when a task contains multiple tests to be executed.  In this case we want the task to be broken out in to a single test per task, allowing the problem test to be isolated and all the remaining tests to pass.

On task failure, the {{gtClass:GtRemoteRunner}} will call {{gtMethod:GtRrTaskRetry>>#retryTask:}} to get the set of tasks to retry, or an empty collection if the task should just fail.
"
Class {
	#name : #GtRrTaskRetry,
	#superclass : #Object,
	#category : #'RemoteRunner-TaskRetry'
}

{ #category : #accessing }
GtRrTaskRetry >> retryTask: aGtRrTask [
	"Answer the collection of tasks to be retried.
	If the task should just fail answer an empty collection."

	^ self subclassResponsibility.
]
