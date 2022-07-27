"
{{gtClass:GtRrJobProgressNotification}} is currently a Proof-of-Concept for providing a notification of job execution progress.

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
	#superclass : #GtNotificationEvent,
	#instVars : [
		'job',
		'successful',
		'failed',
		'notStarted'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #'instance creation' }
GtRrJobProgressNotification class >> job: aGtRrJob [

	^ self new job: aGtRrJob
]

{ #category : #accessing }
GtRrJobProgressNotification >> constructStates [
	^ {
		GtRrDataGroupState new
			name: 'All';
			color: Color transparent;
			items: self job tasks.
		GtRrDataGroupState new
			name: 'Success';
			color: Color lightGreen;
			items: (self job results reject: #hasErrors).
		GtRrDataGroupState new
			name: 'Failure';
			color: Color red;
			items: self job resultsWithErrors.
		GtRrDataGroupState new
			name: 'Not executed';
			color: Color veryVeryLightGray;
			items: (self job tasks reject: #isFinished) }
]

{ #category : #accessing }
GtRrJobProgressNotification >> elementClass [
	"Return a class that when instantiated displayes the notification to user (as a widget)"
	<return: #GtNotificationEventElement>
	
	^ GtRrJobNotificationElement 
]

{ #category : #accessing }
GtRrJobProgressNotification >> job [
	<return: #GtRrJob>

	^ job
]

{ #category : #accessing }
GtRrJobProgressNotification >> job: aGtRrJob [

	job := aGtRrJob.
	self registerNotifications.
]

{ #category : #accessing }
GtRrJobProgressNotification >> notificationLabel [
	^ self job jobName
]

{ #category : #private }
GtRrJobProgressNotification >> registerNotifications [
	"A different approach would be to show the notification using the UI Manager"
	
	GtWorld allInstancesDo: [ :world |
		world showNotification: self ].
]

{ #category : #accessing }
GtRrJobProgressNotification >> runJobAgain [
	"Create a copy of the receiver's job and run it with progress notifications"
	| jobCopy |

	jobCopy := self job copy.
	jobCopy showProgressNotification.
	
	GtRemoteRunner default submitJob: jobCopy.
]

{ #category : #private }
GtRrJobProgressNotification >> setJob: aGtRrJob [
	"Set the job without registering the notification.
	For testing only"

	job := aGtRrJob 
]

{ #category : #accessing }
GtRrJobProgressNotification >> summaryClass [
	"Return a class that when instantiated displays the notification summary to the user"
	^ GtRrJobNotificationSummary
]
