Class {
	#name : #GtRrCompoundTask,
	#superclass : #GtRrTask,
	#instVars : [
		'tasks'
	],
	#category : #'RemoteRunner-Tasks'
}

{ #category : #accessing }
GtRrCompoundTask class >> leJsonV4Name [

	^ #gtRrCompoundTask
]

{ #category : #'instance creation' }
GtRrCompoundTask class >> tasks: aCollection [

	^ self new tasks: aCollection
]

{ #category : #visiting }
GtRrCompoundTask >> acceptVisitor: aVisitor [

	^ aVisitor visitCompoundTask: self
]

{ #category : #accessing }
GtRrCompoundTask >> result: aCollection [

	tasks doWithIndex: [ :task :index |
		task result: (aCollection at: index). ].
	result := tasks.
]

{ #category : #accessing }
GtRrCompoundTask >> run [

	^ tasks collect: [ :task | task run ]
]

{ #category : #accessing }
GtRrCompoundTask >> tasks [

	^ tasks
]

{ #category : #accessing }
GtRrCompoundTask >> tasks: anObject [

	tasks := anObject
]
