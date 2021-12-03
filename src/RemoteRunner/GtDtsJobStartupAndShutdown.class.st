Class {
	#name : #GtDtsJobStartupAndShutdown,
	#superclass : #Object,
	#instVars : [
		'remoteRunner'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #accessing }
GtDtsJobStartupAndShutdown >> remoteRunner [

	^ remoteRunner
]

{ #category : #accessing }
GtDtsJobStartupAndShutdown >> remoteRunner: anObject [

	remoteRunner := anObject
]

{ #category : #'as yet unclassified' }
GtDtsJobStartupAndShutdown >> startupForJob: aGtRrJobContext [
	"Perform actions to start the supplied job context.
	- Use the scheduler to group all the tests in to tasks"

	remoteRunner scheduler schedule: aGtRrJobContext
]
