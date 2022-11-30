"
GtRrTaskDebuggerExceptionStrategy simply passes any exception up the chain and assumes that the debugger will be opened on it.
"
Class {
	#name : #GtRrTaskDebuggerExceptionStrategy,
	#superclass : #GtRrTaskExceptionStrategy,
	#category : #'RemoteRunner-ExceptionHandling'
}

{ #category : #accessing }
GtRrTaskDebuggerExceptionStrategy class >> leJsonV4Name [

	^ #gtRrTaskDebuggerExceptionStrategy
]

{ #category : #testing }
GtRrTaskDebuggerExceptionStrategy >> allowDebugger [
	"Answer a boolean indicating whether the debugger should be opened as the result of an exception"

	^ true
]
