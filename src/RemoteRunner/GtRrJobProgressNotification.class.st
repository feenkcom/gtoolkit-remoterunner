"
GtRrJobProgressNotification is currently a Proof-of-Concept for providing a notification of job execution progress.

The notification must be manually started at the moment, e.g.:

```
job := GtRrTasksJob tasks: 
	((1 to: 30) collect: [ :i |
		GtRrScriptTask script: '0.2 second wait. ', i asString ]).
job := GtRemoteRunner default submitJob: job.
notifier := GtRrJobProgressNotification new job: job.
job.
```

The notification UI will be enhanced to:

- Improve the presentation, e.g. icons, colour, etc.
- Stay in the list until explicitly closed.
- Be able to inspect the job.
"
Class {
	#name : #GtRrJobProgressNotification,
	#superclass : #Object,
	#instVars : [
		'taskCount',
		'failedCount',
		'successfulCount',
		'job'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #updating }
GtRrJobProgressNotification >> announceChange [

	self announcer announce: (JobChange on: self)
]

{ #category : #accessing }
GtRrJobProgressNotification >> announcer [

	^ Job jobAnnouncer
]

{ #category : #accessing }
GtRrJobProgressNotification >> children [
	^ #()
]

{ #category : #'private - hooks' }
GtRrJobProgressNotification >> incrementTaskCompletedCount: anAnnouncement [

	successfulCount := successfulCount + 1.
	self announceChange.
]

{ #category : #'private - hooks' }
GtRrJobProgressNotification >> incrementTaskFailedCount: anAnnouncement [

	failedCount := failedCount + 1.
	self announceChange.
]

{ #category : #accessing }
GtRrJobProgressNotification >> job [

	^ job
]

{ #category : #accessing }
GtRrJobProgressNotification >> job: aGtRrJob [

	self unsubscribeFromJob.
	job := aGtRrJob.
	self subscribeToJob.
	self reset.
	self registerNotifications.
]

{ #category : #'private - hooks' }
GtRrJobProgressNotification >> onJobAnnouncement: anAnnouncement [

	(#(GtRrJobCompletedAnnouncement 
	GtRrJobCancelledAnnouncement 
	GtRrJobTerminatedAnnouncement) 
		includes: anAnnouncement class name) ifFalse: [ ^ self ].

	self unsubscribeFromJob.
	self announcer announce: (JobEnd on: self).
]

{ #category : #accessing }
GtRrJobProgressNotification >> owner [
	^ nil
]

{ #category : #accessing }
GtRrJobProgressNotification >> parent [
	^ nil
]

{ #category : #accessing }
GtRrJobProgressNotification >> progress [

	(taskCount isNil or: [ taskCount = 0]) ifTrue: [ ^ 0 ].
	^ (successfulCount + failedCount) / taskCount
]

{ #category : #private }
GtRrJobProgressNotification >> registerNotifications [

	Job jobAnnouncer announce: (JobStart on: self).
]

{ #category : #initialization }
GtRrJobProgressNotification >> reset [

	taskCount := job taskCount.
	failedCount := successfulCount := 0.
]

{ #category : #private }
GtRrJobProgressNotification >> subscribeToJob [

	job
		when: GtRrTaskCompletedAnnouncement
			send: #incrementTaskCompletedCount: to: self;
		when: GtRrTaskFailedAnnouncement
			send: #incrementTaskFailedCount: to: self;
		when: GtRrJobAnnouncement
			send: #onJobAnnouncement: to: self.
]

{ #category : #accessing }
GtRrJobProgressNotification >> title [

	^ String streamContents: [ :stream |
		stream
			<< 'Remain: ';
			print: (taskCount - successfulCount - failedCount);
			<< ', Done: ';
			print: successfulCount;
			<< ', Failed: ';
			print: failedCount ]
]

{ #category : #private }
GtRrJobProgressNotification >> unsubscribeFromJob [

	job ifNil: [ ^ self ].
	job unsubscribe: self.
]
