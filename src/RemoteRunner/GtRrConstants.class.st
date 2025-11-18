Class {
	#name : #GtRrConstants,
	#superclass : #Object,
	#category : #RemoteRunner
}

{ #category : #accessing }
GtRrConstants class >> changeEventsJobPropertyName [

	^ 'changeEvents'
]

{ #category : #accessing }
GtRrConstants class >> runnerChangesFileJobPropertyName [
	"Answer the property name that holds the changes to be applied to workers for this job"

	^ 'runnerChangesFile'
]
