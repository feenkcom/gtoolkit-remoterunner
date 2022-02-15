"
GtRrAllocatedItemsJob has a number of job items to be performed, but the allocation of items to tasks is delegated to a {{gtClass:GtRrTaskAllocator}}.  This allows different strategies to be used in different circumstances.
"
Class {
	#name : #GtRrAllocatedItemsJob,
	#superclass : #GtRrJob,
	#instVars : [
		'taskAllocator',
		'tasks'
	],
	#category : #'RemoteRunner-Jobs'
}

{ #category : #jsonV3 }
GtRrAllocatedItemsJob class >> leJsonV4AttributeMapping [

	^ super leJsonV4AttributeMapping
		add: #primTaskAllocator -> #taskAllocator;
		add: #primTasks -> #tasks;
		yourself.
]

{ #category : #accessing }
GtRrAllocatedItemsJob >> allItems [
	"Answer all the tests / examples to be executed"

	^ self subclassResponsibility
]

{ #category : #private }
GtRrAllocatedItemsJob >> defaultTaskAllocator [
	"Answer the default object responsible for grouping job items in to job tasks"
	<return: #GtRrTaskAllocator>

	^ self subclassResponsibility 
]

{ #category : #private }
GtRrAllocatedItemsJob >> primTaskAllocator [

	^ taskAllocator 
]

{ #category : #private }
GtRrAllocatedItemsJob >> primTaskAllocator: anObject [

	taskAllocator := anObject
]

{ #category : #private }
GtRrAllocatedItemsJob >> primTasks [

	^ tasks
]

{ #category : #private }
GtRrAllocatedItemsJob >> primTasks: anObject [

	tasks := anObject
]

{ #category : #private }
GtRrAllocatedItemsJob >> taskAllocator [
	"Answer the object responsible for grouping job items in to job tasks"
	<return: #GtRrTaskAllocator>

	^ taskAllocator ifNil: [ taskAllocator := self defaultTaskAllocator ]
]

{ #category : #accessing }
GtRrAllocatedItemsJob >> taskAllocator: aGtRrTaskAllocator [

	taskAllocator := aGtRrTaskAllocator
]

{ #category : #accessing }
GtRrAllocatedItemsJob >> tasks [

	^ tasks ifNil: [ tasks := self taskAllocator allocateItems: self allItems ]
]

{ #category : #accessing }
GtRrAllocatedItemsJob >> tasks: aCollection [

	tasks := aCollection
]
