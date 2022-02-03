Class {
	#name : #GtRrOneAtATimeTestsTaskAllocator,
	#superclass : #GtRrTaskAllocator,
	#category : #'RemoteRunner-Tests'
}

{ #category : #accessing }
GtRrOneAtATimeTestsTaskAllocator class >> leJsonV4Name [ 

	^ #gtRrOneAtATimeTestsTaskAllocator
]

{ #category : #scheduling }
GtRrOneAtATimeTestsTaskAllocator >> allocateItems: aCollection [

	^ aCollection collect: [ :test |
		GtRrTestTask tests: { test key -> { test value } } asDictionary ].
]
