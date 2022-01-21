Class {
	#name : #GtRrScriptTask,
	#superclass : #GtRrTask,
	#instVars : [
		'script'
	],
	#category : #'RemoteRunner-Tests'
}

{ #category : #jsonV3 }
GtRrScriptTask class >> leJsonV4AttributeMapping [

	^ super leJsonV4AttributeMapping
		  add: #script -> #script;
		  yourself
]

{ #category : #accessing }
GtRrScriptTask class >> leJsonV4Name [

	^ #gtRrScriptTask
]

{ #category : #'instance creation' }
GtRrScriptTask class >> script: aString [

	^ self new
		  script: aString;
		  yourself
]

{ #category : #printing }
GtRrScriptTask >> printOn: aStream [

	super printOn: aStream.
	aStream 
		nextPut: $(;
		<< script;
		nextPut: $)
]

{ #category : #accessing }
GtRrScriptTask >> script [

	^ script
]

{ #category : #accessing }
GtRrScriptTask >> script: anObject [

	script := anObject
]

{ #category : #running }
GtRrScriptTask >> value [

	^ self class compiler
		source: script;
		receiver: nil;
		evaluate
]
