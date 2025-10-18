"
GtRrCodeSyncJob is a collection of {{gtClass:GtRrCodeSyncTask}} for propagating code changes to synced workers.
"
Class {
	#name : #GtRrCodeSyncJob,
	#superclass : #GtRrJob,
	#instVars : [
		'serializedChanges',
		'entries',
		'templateTask'
	],
	#category : #'RemoteRunner-Runner-CodeSync'
}

{ #category : #'instance creation' }
GtRrCodeSyncJob class >> entries: aCollection [
	"aCollection of OmEntry"

	^ self new entries: aCollection
]

{ #category : #jsonV4 }
GtRrCodeSyncJob class >> leJsonV4AttributeMapping [
	"Answer the Array of attribute to store keys.
	Subclasses should override this with their attributes."

	^ super leJsonV4AttributeMapping
		add: #stonEntries -> #entries;
		yourself
]

{ #category : #jsonV4 }
GtRrCodeSyncJob class >> leJsonV4Name [

	^ #gtRrCodeSyncJob
]

{ #category : #accessing }
GtRrCodeSyncJob >> entries [
	^ entries
]

{ #category : #accessing }
GtRrCodeSyncJob >> entries: anObject [
	entries := anObject
]

{ #category : #'private - running' }
GtRrCodeSyncJob >> markJobCompleted [

	super markJobCompleted.
	templateTask ifNotNil:
		[ templateTask onJobCompleted ].
]

{ #category : #serialization }
GtRrCodeSyncJob >> stonEntries [
	"Answer the serialised entries."

	^ STON toString: entries.
]

{ #category : #serialization }
GtRrCodeSyncJob >> stonEntries: aString [
	"Set the entries from the serialised string."

	entries := STON fromString: aString.
]

{ #category : #accessing }
GtRrCodeSyncJob >> tasks [
	"This shouldn't be called as #tasksFor: has been overwritten"

	^ self shouldNotImplement
]

{ #category : #accessing }
GtRrCodeSyncJob >> tasksFor: aRemoteRunner [
	| tasks |

	tasks := OrderedCollection new.
	"Create a sync task and copy it for each worker.
	This allows the task to serialise the changes once and re-use for each worker,
	while allowing different serialisation approaches"
	templateTask := (GtRrCodeSyncTask forChanges: entries)
		entries: entries.
	aRemoteRunner registeredWorkersDo: [ :aWorkerConnection |
		(aWorkerConnection attributes at: #codeSynced ifAbsent: [ false ]) ifTrue:
			[ tasks add: (templateTask copy
				workerId: (aWorkerConnection attributes at: #id)) ] ].
	"If there were no tasks generated, there are no code-sync workers available, register the error.
	The job will be marked completed at the end of job startup."
	tasks ifEmpty:
		[ self errorDetails: (GtRrErrorDetails new
			errorMessage: 'No code-sync workers available';
			setTrace) ].
	^ tasks
]

{ #category : #accessing }
GtRrCodeSyncJob >> templateTask [
	^ templateTask
]
