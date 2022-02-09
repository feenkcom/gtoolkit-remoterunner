Class {
	#name : #GtRrClassAtATimeTestsTaskAllocator,
	#superclass : #GtRrTaskAllocator,
	#category : #'RemoteRunner-Tests'
}

{ #category : #accessing }
GtRrClassAtATimeTestsTaskAllocator class >> leJsonV4Name [ 

	^ #gtRrClassAtATimeTestsTaskAllocator
]

{ #category : #allocating }
GtRrClassAtATimeTestsTaskAllocator >> allocateItems: aCollection [

	^ (aCollection groupedBy: #key) associations collect: [ :assoc |
		GtRrTestTask tests: 
			{ assoc key -> (assoc value collect: #value) } asDictionary ].
]
