Class {
	#name : #GtRrTimeoutTaskError,
	#superclass : #Error,
	#instVars : [
		'processesDetails'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #accessing }
GtRrTimeoutTaskError >> initializeProcessesDetails [

	processesDetails := String streamContents: [ :aStream |
		| allProcesses gtQuiescentProcesses |
		aStream nextPutAll: 'Processes and their stacks: '; cr.
		
		gtQuiescentProcesses := Processor gtQuiescentProcesses.
		
		allProcesses := Process allSubInstances 
			reject: [:each | each isTerminated ].
		allProcesses sort: [:a :b | a priority >= b priority].
		
		allProcesses do: [ :aProcess | | ctx |
			aStream 
				nextPutAll: 'Process: '; 
				print: aProcess; 
				nextPutAll: '; priority: '; 
				print: aProcess priority.
			aStream 
				nextPutAll: '; Quiescent: '; 
				print: (gtQuiescentProcesses includes: aProcess).
			aStream
				nextPutAll: ';  stack:'; cr; cr.

			ctx := aProcess isActiveProcess 
				ifTrue: [ thisContext sender ] 
				ifFalse: [ aProcess suspendedContext ].
			ctx ifNotNil: [
				(ctx stackOfSize: 100) do: [:s | aStream print: s; cr ]].
			aStream nextPutAll: '------------------------------'; cr; cr.
		]].

]

{ #category : #accessing }
GtRrTimeoutTaskError >> pharoLinkAdditionalData [
	^ processesDetails
]

{ #category : #accessing }
GtRrTimeoutTaskError >> processesDetails [
	^ processesDetails
]
