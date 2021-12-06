Class {
	#name : #GtRrOneAtATimeTestsTaskAllocator,
	#superclass : #GtRrTaskAllocator,
	#category : #'RemoteRunner-Tests'
}

{ #category : #scheduling }
GtRrOneAtATimeTestsTaskAllocator >> allocateItems: aCollection [

	^ aCollection collect: [ :test |
		GtRrTestTask tests: { test key -> { test value } } asDictionary ].
]
