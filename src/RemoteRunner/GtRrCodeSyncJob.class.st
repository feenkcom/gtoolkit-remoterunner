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

{ #category : #initialization }
GtRrCodeSyncJob >> initialize [

	super initialize.
	timeout := 1 minute
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

	^ tasks
]

{ #category : #accessing }
GtRrCodeSyncJob >> value [

	tasks := scheduler executors
		         select: [ :e | e attributes includesKey: #codeSynced ]
		         thenCollect: [ :e | 
			         GtRrCodeSyncTask
				         serializedChanges: serializedChanges
				         workerId: (e attributes at: #id) ].
	tasks do: [ :e | scheduler schedule: e ]
]
