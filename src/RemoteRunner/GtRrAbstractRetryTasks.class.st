"
Subclasses hold information about which tasks / checks were retried in task completion announcements, .
"
Class {
	#name : #GtRrAbstractRetryTasks,
	#superclass : #Object,
	#category : 'RemoteRunner-Announcements'
}

{ #category : #'instance creation' }
GtRrAbstractRetryTasks class >> fromTasks: aCollectionOfTasks [

	^ self new
]
