"
I represent an action performed when a RemoteRunner worker starts. I provide a descriptive title and a priority used to order startup actions. Subclasses implement #run.
"
Class {
	#name : #GtRrWorkerStartupAction,
	#superclass : #Object,
	#instVars : [
		'title',
		'priority'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #initialization }
GtRrWorkerStartupAction >> initialize [
	super initialize.
	title := self class name.
	priority := 50
]

{ #category : #accessing }
GtRrWorkerStartupAction >> priority [
	^ priority
]

{ #category : #accessing }
GtRrWorkerStartupAction >> priority: aNumber [
	priority := aNumber
]

{ #category : #running }
GtRrWorkerStartupAction >> run [
	self subclassResponsibility
]

{ #category : #accessing }
GtRrWorkerStartupAction >> title [
	^ title
]

{ #category : #accessing }
GtRrWorkerStartupAction >> title: aString [
	title := aString
]
