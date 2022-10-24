Class {
	#name : #GtRrJobAnnouncement,
	#superclass : #GtRemoteRunnerAnnouncement,
	#instVars : [
		'job'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #'instance creation' }
GtRrJobAnnouncement class >> fromStonDictionary: aDictionary [

	^ (super fromStonDictionary: aDictionary)
		job: (aDictionary at: #job);
		yourself

]

{ #category : #'instance creation' }
GtRrJobAnnouncement class >> job: aGtRrJob [

	^ self new job: aGtRrJob
]

{ #category : #converting }
GtRrJobAnnouncement >> asDictionary [

	^ super asDictionary
		at: #job put: job;
		yourself.
]

{ #category : #accessing }
GtRrJobAnnouncement >> job [

	^ job
]

{ #category : #accessing }
GtRrJobAnnouncement >> job: anObject [

	job := anObject
]

{ #category : #printing }
GtRrJobAnnouncement >> printOneLineContentsOn: stream [

	job ifNil: [ ^ self ].
	stream print: job.

]
