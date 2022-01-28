"
A GtRrCodeSyncTask is sent to each code synced remote runner worker every time a change is made to the system's code.
"
Class {
	#name : #GtRrCodeSyncTask,
	#superclass : #GtRrTask,
	#instVars : [
		'serializedChanges'
	],
	#category : #'RemoteRunner-Runner-CodeSync'
}

{ #category : #accessing }
GtRrCodeSyncTask class >> leJsonV4Name [

	^ #gtRrCodeSyncTask
]

{ #category : #accessing }
GtRrCodeSyncTask class >> serializedChanges: aFuelStringOfCollection workerId: aString [

	^ self new
		  serializedChanges: aFuelStringOfCollection;
		  constraint: (GtRrEqualsConstraint attribute: #id value: aString);
		  yourself
]

{ #category : #'gt-extensions' }
GtRrCodeSyncTask >> gtChangesFor: aView [
	<gtView>

	serializedChanges ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Changes';
		priority: 20;
		object: [ LanguageLinkUtils base64Decode: serializedChanges readStream ];
		view: #gtLiveFor:
]

{ #category : #executing }
GtRrCodeSyncTask >> run [

	(LanguageLinkUtils base64Decode: serializedChanges readStream) do:
		#applyCodeChange.
	^ true
]

{ #category : #accessing }
GtRrCodeSyncTask >> serializedChanges [

	^ serializedChanges
]

{ #category : #accessing }
GtRrCodeSyncTask >> serializedChanges: anObject [

	serializedChanges := anObject
]
