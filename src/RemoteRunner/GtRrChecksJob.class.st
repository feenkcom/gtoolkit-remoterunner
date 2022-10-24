"
GtRrChecksJob expects to hold {{gtClass:GtRrAbstractExamplesTask}} subclasses as its tasks.
"
Class {
	#name : #GtRrChecksJob,
	#superclass : #GtRrTasksJob,
	#category : #'RemoteRunner-Jobs'
}

{ #category : #accessing }
GtRrChecksJob class >> exampleNames: anArray [

	^ self new tasks: { (GtRrExplicitExampleTask exampleNames: anArray) }
]

{ #category : #accessing }
GtRrChecksJob class >> leJsonV4Name [

	^ #gtRrChecksJob
]

{ #category : #accessing }
GtRrChecksJob class >> sunitTestNames: anArray [

	^ self new tasks: { (GtRrExplicitSUnitTask sunitTestNames: anArray) }
]
