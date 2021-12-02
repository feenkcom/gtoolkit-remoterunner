Class {
	#name : #GtRrOneAtATimeTaskScheduler,
	#superclass : #GtRrTaskScheduler,
	#category : #'RemoteRunner-Model'
}

{ #category : #schedulling }
GtRrOneAtATimeTaskScheduler >> schedule: aGtRrJobContext [

	aGtRrJobContext allTests do: [ :test |
		aGtRrJobContext pendingTasks nextPut:
			(GtDtsTestTask tests: { test key -> { test value } } asDictionary) ].
]
