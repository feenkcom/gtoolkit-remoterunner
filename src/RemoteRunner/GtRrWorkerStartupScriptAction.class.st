"
I am a worker startup action that evaluates a Smalltalk script string when run.
"
Class {
	#name : #GtRrWorkerStartupScriptAction,
	#superclass : #GtRrWorkerStartupAction,
	#instVars : [
		'script'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #'instance creation' }
GtRrWorkerStartupScriptAction class >> script: aString [
	^ self new script: aString
]

{ #category : #running }
GtRrWorkerStartupScriptAction >> run [
	^ self class compiler
		source: script;
		receiver: nil;
		evaluate
]

{ #category : #accessing }
GtRrWorkerStartupScriptAction >> script [
	^ script
]

{ #category : #accessing }
GtRrWorkerStartupScriptAction >> script: aString [
	script := aString
]
