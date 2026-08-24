"
I am a worker startup action that evaluates a BlockClosure when run.
"
Class {
	#name : #GtRrWorkerStartupBlockAction,
	#superclass : #GtRrWorkerStartupAction,
	#instVars : [
		'block'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #'instance creation' }
GtRrWorkerStartupBlockAction class >> block: aBlockClosure [
	^ self new block: aBlockClosure
]

{ #category : #accessing }
GtRrWorkerStartupBlockAction >> block [
	^ block
]

{ #category : #accessing }
GtRrWorkerStartupBlockAction >> block: aBlockClosure [
	block := aBlockClosure
]

{ #category : #running }
GtRrWorkerStartupBlockAction >> run [
	^ block cull: self
]
