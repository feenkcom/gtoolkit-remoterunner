"
{{gtClass:GtRrInImageConstraint}} will only run tasks on a worker that is part of the RemoteRunner image.

This relies on the workers correctly setting the #workerInImage attribute.
"
Class {
	#name : #GtRrInImageConstraint,
	#superclass : #GtRrConstraint,
	#traits : 'TGtUniqueInstance',
	#classTraits : 'TGtUniqueInstance classTrait',
	#category : 'RemoteRunner-Constraints'
}

{ #category : #accessing }
GtRrInImageConstraint class >> leJsonV4Name [

	^ #gtRrInImageConstraint
]

{ #category : #testing }
GtRrInImageConstraint >> matches: aDictionary [

	^ aDictionary at: #workerInImage ifAbsent: [ false ]
]
