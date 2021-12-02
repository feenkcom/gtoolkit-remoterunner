Class {
	#name : #GtDtsJobStartupAndShutdown,
	#superclass : #Object,
	#instVars : [
		'rrManager'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #'as yet unclassified' }
GtDtsJobStartupAndShutdown >> startupForJob: aGtRrJobContext [
	"Perform actions to start the supplied job context.
	- Use the scheduler to group all the tests in to tasks"

	rrManager scheduler schedule: aGtRrJobContext
]
