Class {
	#name : #GtRrUIManager,
	#superclass : #NonInteractiveUIManager,
	#category : #'RemoteRunner-Worker'
}

{ #category : #'ui requests' }
GtRrUIManager >> syntaxErrorNotificationDefaultAction: aSyntaxErrorNotification [
	"In an image running as a Gt remote runner worker, syntax errors should just be treated like any other unhandled exception"

	^ aSyntaxErrorNotification raiseUnhandledError
]
