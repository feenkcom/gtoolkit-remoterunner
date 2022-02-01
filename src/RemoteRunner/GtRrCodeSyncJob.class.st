"
GtRrCodeSyncJob is a collection of {{gtClass:GtRrCodeSyncTask}} for propagating code changes to synced workers.
"
Class {
	#name : #GtRrCodeSyncJob,
	#superclass : #GtRrJob,
	#instVars : [
		'serializedChanges'
	],
	#category : #'RemoteRunner-Runner-CodeSync'
}

{ #category : #jsonV3 }
GtRrCodeSyncJob class >> leJsonV4AttributeMapping [
	"Answer the Array of attribute to store keys.
	Subclasses should override this with their attributes."

	^ super leJsonV4AttributeMapping
		add: #serializedChanges -> #serializedChanges;
		yourself
]

{ #category : #accessing }
GtRrCodeSyncJob class >> leJsonV4Name [

	^ #gtRrCodeSyncJob
]

{ #category : #accessing }
GtRrCodeSyncJob class >> serializedChanges: aFuelStringOfCollection [

	^ self new
		  serializedChanges: aFuelStringOfCollection;
		  yourself
]

{ #category : #accessing }
GtRrCodeSyncJob >> serializedChanges [

	^ serializedChanges
]

{ #category : #accessing }
GtRrCodeSyncJob >> serializedChanges: anObject [

	serializedChanges := anObject
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
	aRemoteRunner registeredWorkersDo: [ :aWorkerConnection |
		(aWorkerConnection details at: #codeSynced ifAbsent: [ false ]) ifTrue:
			[ tasks add: (GtRrCodeSyncTask
				serializedChanges: serializedChanges
				workerId: (aWorkerConnection details at: #id)) ] ].
	^ tasks
]
