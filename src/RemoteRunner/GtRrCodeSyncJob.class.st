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
		(aWorkerConnection details includesKey: #codeSynced) ifTrue:
			[ tasks add: (GtRrCodeSyncTask
				serializedChanges: serializedChanges
				workerId: (aWorkerConnection details at: #id)) ] ].
	^ tasks
]
