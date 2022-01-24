Class {
	#name : #GtRrCodeSyncTask,
	#superclass : #GtRrTask,
	#instVars : [
		'serializedChanges'
	],
	#category : #'RemoteRunner-Runner-CodeSync'
}

{ #category : #jsonV3 }
GtRrCodeSyncTask class >> leJsonV4AttributeMapping [

	^ super leJsonV4AttributeMapping
		  add: #serializedChanges -> #serializedChanges;
		  yourself
]

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

{ #category : #initialization }
GtRrCodeSyncTask >> initialize [

	super initialize.
	timeout := 1 minute
]

{ #category : #accessing }
GtRrCodeSyncTask >> serializedChanges [

	^ serializedChanges
]

{ #category : #accessing }
GtRrCodeSyncTask >> serializedChanges: anObject [

	serializedChanges := anObject
]

{ #category : #executing }
GtRrCodeSyncTask >> value [

	| changes |
	changes := LanguageLinkUtils base64Decode:
		           serializedChanges readStream.
	changes do: #applyCodeChange.
	^ true
]
