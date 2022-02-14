Class {
	#name : #GtRrExplicitExampleTask,
	#superclass : #GtRrExamplesTask,
	#instVars : [
		'examples'
	],
	#category : #'RemoteRunner-Tests'
}

{ #category : #accessing }
GtRrExplicitExampleTask >> examples [

	^ examples
]

{ #category : #accessing }
GtRrExplicitExampleTask >> examples: anObject [

	examples := anObject
]

{ #category : #'private - running' }
GtRrExplicitExampleTask >> group [

	^ GtExplicitExampleGroup new examples: examples
]
