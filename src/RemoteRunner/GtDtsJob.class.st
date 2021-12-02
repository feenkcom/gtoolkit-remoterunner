Class {
	#name : #GtDtsJob,
	#superclass : #Object,
	#traits : 'TGtAnnouncer',
	#classTraits : 'TGtAnnouncer classTrait',
	#instVars : [
		'uid',
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
GtDtsJob >> addResults: aCollection [
	"Add the supplied results to the receiver and notify dependents"

	self results addResults: aCollection.
	self flag: #TODO "announce the addition"
]

{ #category : #accessing }
GtDtsJob >> allTests [
	"Answer an array of all individual tests in the form #ClassName -> #Selector"

	^ self subclassResponsibility
]

{ #category : #accessing }
GtDtsJob >> announcer [

	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #accessing }
GtDtsJob >> classNames [

	^ classNames
]

{ #category : #accessing }
GtDtsJob >> classNames: anObject [

	classNames := anObject
]

{ #category : #accessing }
GtDtsJob >> packageNames [

	^ packageNames
]

{ #category : #accessing }
GtDtsJob >> packageNames: anObject [

	packageNames := anObject
]

{ #category : #accessing }
GtDtsJob >> results [

	^ results ifNil: [ results := GtDtsJobResults new ]
]

{ #category : #accessing }
GtDtsJob >> state [

	^ state
]

{ #category : #accessing }
GtDtsJob >> state: anObject [

	state := anObject
]

{ #category : #accessing }
GtDtsJob >> testNames [

	^ testNames
]

{ #category : #accessing }
GtDtsJob >> testNames: anObject [

	testNames := anObject
]

{ #category : #accessing }
GtDtsJob >> uid [

	^ uid
]
