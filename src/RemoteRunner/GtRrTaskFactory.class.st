Class {
	#name : #GtRrTaskFactory,
	#superclass : #Object,
	#instVars : [
		'stream',
		'taskTimeout'
	],
	#category : #'RemoteRunner-Tasks'
}

{ #category : #'private - utility' }
GtRrTaskFactory >> classWithName: aString [

	^ (aString endsWith: ' class')
		ifTrue: [ (self class environment at: (aString copyFrom: 1 to: aString size - 6) asSymbol) class ]
		ifFalse: [ self class environment at: aString asSymbol ].
]

{ #category : #'gt - extensions' }
GtRrTaskFactory >> gtViewTasksFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Tasks';
		priority: 10; 
		items: [ stream contents ];
		column: 'Type' text: [ :aTask | aTask className ] width: 200;
		column: 'Task' text: [ :aTask | aTask supplementalDescription ];
		column: 'Duration' text: [ :aTask | aTask duration ] width: 150
]

{ #category : #initialization }
GtRrTaskFactory >> initialize [

	super initialize.
	self reset.
]

{ #category : #'api - generation' }
GtRrTaskFactory >> job [

	^ GtRrTasksJob new tasks: self tasks.
]

{ #category : #initialization }
GtRrTaskFactory >> reset [

	stream := Array new writeStream.
]

{ #category : #accessing }
GtRrTaskFactory >> taskTimeout [
	<return: #Duration or: nil>

	^ taskTimeout
]

{ #category : #accessing }
GtRrTaskFactory >> taskTimeout: aDuration [

	taskTimeout := aDuration
]

{ #category : #'api - generation' }
GtRrTaskFactory >> tasks [

	^ stream contents
]
