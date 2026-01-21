Class {
	#name : #GtRrRetryTasks,
	#superclass : #GtRrAbstractRetryTasks,
	#instVars : [
		'taskIds'
	],
	#category : 'RemoteRunner-Announcements'
}

{ #category : #'instance creation' }
GtRrRetryTasks class >> fromTasks: aCollectionOfTasks [

	^ self new taskIds: (aCollectionOfTasks collect: #taskId)
]

{ #category : #serialization }
GtRrRetryTasks class >> leJsonV4Name [

	^ #gtRrRetryTasks
]

{ #category : #accessing }
GtRrRetryTasks >> taskIds [
	^ taskIds
]

{ #category : #accessing }
GtRrRetryTasks >> taskIds: anObject [
	taskIds := anObject
]
