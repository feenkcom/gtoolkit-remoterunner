Class {
	#name : #GtRrScriptTask,
	#superclass : #GtRrTask,
	#instVars : [
		'script'
	],
	#category : #'RemoteRunner-Tasks'
}

{ #category : #accessing }
GtRrScriptTask class >> leJsonV4Name [

	^ #gtRrScriptTask
]

{ #category : #'instance creation' }
GtRrScriptTask class >> script: aString [

	^ self new script: aString
]

{ #category : #running }
GtRrScriptTask >> run [

	^ self class compiler
		source: script;
		receiver: nil;
		evaluate
]

{ #category : #accessing }
GtRrScriptTask >> script [

	^ script
]

{ #category : #accessing }
GtRrScriptTask >> script: anObject [

	script := anObject
]
