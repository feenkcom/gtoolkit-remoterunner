Class {
	#name : #GtRrMemoryLoggerPrePostTaskAction,
	#superclass : #GtRrPrePostTaskAction,
	#instVars : [
		'logger'
	],
	#category : #'RemoteRunner-PrePostTaskActions'
}

{ #category : #actions }
GtRrMemoryLoggerPrePostTaskAction >> postTaskAction: aGtRrTask [

	logger stop.
	aGtRrTask executionData additionalData
		at: #logger
		put: (STON toString: logger)
]

{ #category : #actions }
GtRrMemoryLoggerPrePostTaskAction >> preTaskAction: aGtRrTask [

	logger := MemoryLogger new startFor: StringSignal, MethodStackSignal
]
