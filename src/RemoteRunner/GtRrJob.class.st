Class {
	#name : #GtRrJob,
	#superclass : #Object,
	#traits : 'TGtAnnouncer',
	#classTraits : 'TGtAnnouncer classTrait',
	#instVars : [
		'uid',
		'platforms',
		'packageNames',
		'classNames',
		'testNames',
		'state',
		'results',
		'announcer'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #accessing }
GtRrJob >> addResults: aCollection [
	"Add the supplied results to the receiver and notify dependents"

	self results addResults: aCollection.
	self flag: #TODO "announce the addition"
]

{ #category : #accessing }
GtRrJob >> allItems [
	"Answer an array of all individual items to be run in the form #ClassName -> #Selector"

	^ self subclassResponsibility
]

{ #category : #accessing }
GtRrJob >> announcer [

	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #accessing }
GtRrJob >> classNames [
	<return: #Array of: #Symbol>

	^ classNames
]

{ #category : #accessing }
GtRrJob >> classNames: anObject [

	classNames := anObject
]

{ #category : #initialization }
GtRrJob >> initialize [

	super initialize.
	uid := UUID new.
	packageNames := #().
	classNames := #().
	testNames := #().
]

{ #category : #accessing }
GtRrJob >> packageNames [
	<return: #Array of: #String>

	^ packageNames
]

{ #category : #accessing }
GtRrJob >> packageNames: anObject [

	packageNames := anObject
]

{ #category : #accessing }
GtRrJob >> platforms [

	^ platforms
]

{ #category : #accessing }
GtRrJob >> platforms: anObject [

	platforms := anObject
]

{ #category : #accessing }
GtRrJob >> results [

	^ results ifNil: [ results := GtDtsJobResults new ]
]

{ #category : #accessing }
GtRrJob >> state [

	^ state
]

{ #category : #accessing }
GtRrJob >> state: anObject [

	state := anObject
]

{ #category : #accessing }
GtRrJob >> testNames [
	"Answer the collection of test names.
	Each test name is #ClassName -> #testSelector"
	<return: #Array of: #Association>
	
	^ testNames
]

{ #category : #accessing }
GtRrJob >> testNames: anObject [

	testNames := anObject
]

{ #category : #accessing }
GtRrJob >> uid [

	^ uid
]
