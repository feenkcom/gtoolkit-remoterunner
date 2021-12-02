Class {
	#name : #GtRrOneAtATimeTaskScheduler,
	#superclass : #GtRrTaskScheduler,
	#category : #'RemoteRunner-Model'
}

{ #category : #schedulling }
GtRrOneAtATimeTaskScheduler >> schedule: aGtRrJobContext [

	aGtRrJobContext allItems do: [ :test |
		aGtRrJobContext addTask:
			(GtRrTestTask tests: { test key -> { test value } } asDictionary) ].
]
