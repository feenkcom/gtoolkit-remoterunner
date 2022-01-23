Class {
	#name : #GtRrProcessReplacedAnnouncement,
	#superclass : #GtRrAnnouncement,
	#instVars : [
		'before',
		'after'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #'instance creation' }
GtRrProcessReplacedAnnouncement class >> before: aProcess after: anotherProcess [

	^ self new
		  initializeBefore: aProcess after: anotherProcess;
		  yourself
]

{ #category : #ui }
GtRrProcessReplacedAnnouncement >> gtStderrFor: aView [

	<gtView>
	before ifNil: [ ^ aView empty ].
	^ aView forward
		  title: 'stderr before';
		  priority: 10;
		  object: [ before ];
		  view: #gtStderrFor:
]

{ #category : #ui }
GtRrProcessReplacedAnnouncement >> gtStdoutFor: aView [

	<gtView>
	before ifNil: [ ^ aView empty ].
	^ aView forward
		  title: 'stdout before';
		  priority: 10;
		  object: [ before ];
		  view: #gtStdoutFor:
]

{ #category : #initialization }
GtRrProcessReplacedAnnouncement >> initializeBefore: aProcess after: anotherProcess [

	before := aProcess.
	after := anotherProcess
]
