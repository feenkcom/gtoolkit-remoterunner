"
GtRrAllocatedItemsJob has a number of job items to be performed, but the allocation of items to tasks is delegated to a {{gtClass:GtRrTaskAllocator}}.  This allows different strategies to be used in different circumstances.
"
Class {
	#name : #GtRrAllocatedItemsJob,
	#superclass : #GtRrJob,
	#category : #'RemoteRunner-Jobs'
}

{ #category : #accessing }
GtRrAllocatedItemsJob >> allItems [
	"Answer all the tests / examples to be executed"

	^ self subclassResponsibility
]

{ #category : #private }
GtRrAllocatedItemsJob >> taskAllocator [
	"Answer the object responsible for grouping job items in to job tasks"
	<return: #GtRrTaskAllocator>

	^ self subclassResponsibility
]

{ #category : #accessing }
GtRrAllocatedItemsJob >> tasks [

	^ self taskAllocator allocateItems: self allItems
]
