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

{ #category : #visiting }
GtRrScriptTask >> acceptVisitor: aVisitor [

	^ aVisitor visitScriptTask: self
]

{ #category : #accessing }
GtRrScriptTask >> gtScriptFor: aView [
	<gtView>
	
	script ifNil: [ ^ aView empty ].
	^ aView text
		title: 'Script';
		priority: 10;
		text: [ script asRopedText glamorousCodeFont ]
]

{ #category : #printing }
GtRrScriptTask >> printOn: aStream [

	super printOn: aStream.
	aStream 
		nextPut: $(;
		<< script;
		nextPut: $)
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
