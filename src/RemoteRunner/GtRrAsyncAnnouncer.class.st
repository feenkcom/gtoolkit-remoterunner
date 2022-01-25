Class {
	#name : #GtRrAsyncAnnouncer,
	#superclass : #Announcer,
	#instVars : [
		'scheduler'
	],
	#category : #'RemoteRunner-Runner-Support'
}

{ #category : #scheduler }
GtRrAsyncAnnouncer class >> scheduler: aScheduler [

	^ self new
		  initializeScheduler: aScheduler;
		  yourself
]

{ #category : #announcer }
GtRrAsyncAnnouncer >> announce: anAnnouncement [

	scheduler schedule: [ super announce: anAnnouncement ].
	^ anAnnouncement
]

{ #category : #initialization }
GtRrAsyncAnnouncer >> initializeScheduler: aScheduler [

	scheduler := aScheduler
]
