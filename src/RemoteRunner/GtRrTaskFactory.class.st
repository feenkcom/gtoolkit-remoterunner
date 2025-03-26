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

{ #category : #'as yet unclassified' }
GtRrTaskFactory >> groupTasksByAverageTime [

	stream := (GtRrAverageTimeExampleAllocator new
		allocateTasks: stream contents) readStream.
]

{ #category : #'gt - extensions' }
GtRrTaskFactory >> gtViewTasksByWorkerFor: aView [
	<gtView>
	
	^ aView columnedList
		title: 'Executed tasks (by worker)';
		priority: 20; 
		items: [ 
			self startedTasksGroupedByWorker associations  ];
		column: 'Id' text: [ :assoc | assoc key ] width:300;
		column: 'Task' text: [ :assoc | assoc value size ];
		column: 'Duration' text: [ :assoc | 
			((assoc value 
				collect: [ :aTask | aTask duration ])
				reject: [ :aDuration | aDuration isNil ]) sum ];
		send: [ :assoc | 
			GtRrTasksGroup withAll: assoc value ]
]

{ #category : #'gt - extensions' }
GtRrTaskFactory >> gtViewTasksFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Tasks';
		priority: 10; 
		items: [ self tasks ];
		column: 'Type' text: [ :aTask | aTask className ] width: 200;
		column: 'Task' text: [ :aTask | aTask supplementalDescription ];
		column: 'Duration' text: [ :aTask | 
			aTask duration ifNil: [ '-' ] ] width: 150
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

{ #category : #'accessing - grouping' }
GtRrTaskFactory >> startedTasksGroupedByWorker [
	^ (self tasks
		reject: [ :aTask |
			aTask isNotStarted ])
	 	groupedBy: [ :aTask |
			aTask workerId ]
]

{ #category : #'api - generation' }
GtRrTaskFactory >> tasks [

	^ stream contents
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
