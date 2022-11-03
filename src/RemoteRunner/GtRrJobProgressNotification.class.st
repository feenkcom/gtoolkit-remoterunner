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
		'taskResults'
	],
	#category : #'RemoteRunner-Jobs-Notifications'
}

{ #category : #'instance creation' }
GtRrJobProgressNotification class >> job: aGtRrJob [

	^ self new 
		job: aGtRrJob;
		registerNotifications
]

{ #category : #callbacks }
GtRrJobProgressNotification >> actOnTaskCompletedFor: anAnnouncement [
	self addTaskResult: anAnnouncement taskResult
]

{ #category : #accessing }
GtRrJobProgressNotification >> addTaskResult: aTaskResult [
	taskResults add: aTaskResult
]

{ #category : #accessing }
GtRrJobProgressNotification >> constructStates [
	^ {
		GtRrDataGroupState new
			name: 'All';
			items: self job tasks.
		GtRrDataGroupState new
			name: 'Success';
			testCaseState: GtPharoMethodTestCasePassedState;
			items: (self job results reject: #hasErrors).
		GtRrDataGroupState new
			name: 'Failure';
			testCaseState: GtPharoMethodTestCasePassedState;
			items: self job resultsWithErrors.
		GtRrDataGroupState new
			name: 'Not executed';
			testCaseState: GtPharoMethodTestCasePassedState;
			items: (self job tasks reject: #isFinished) }
]

{ #category : #accessing }
GtRrJobProgressNotification >> elementClass [
	"Return a class that when instantiated displayes the notification to user (as a widget)"
	<return: #GtNotificationEventElement>
	
	^ GtRrJobNotificationElement 
]

{ #category : #'gt - extensions' }
GtRrJobProgressNotification >> gtViewNotificationStatesFor: aView [
	<gtView>
	
	^ aView columnedList
		title: 'Notification States';
		items: [ self constructStates];
		column: 'Color' icon: [ :aState | 
			GtPharoTestCaseUtility newColoredIcon: aState color ];
		column: 'State' text: [ :aState | aState name ];
		column: 'Item Count' text: [ :aState | aState itemCount ]
]

{ #category : #'gt - extensions' }
GtRrJobProgressNotification >> gtViewTaskResultsFor: aView [
	<gtView>
	
	^ aView list
		title: 'Task Results';
		items: [ self taskResults]
]

{ #category : #accessing }
GtRrJobProgressNotification >> job [
	<return: #GtRrJob>

	^ job
]

{ #category : #accessing }
GtRrJobProgressNotification >> job: aGtRrJob [
	job ifNotNil: [
		self unsubscribeFromJob ].
	
	job := aGtRrJob.
	taskResults := OrderedCollection new.
	
	self subscribeToJob.
]

{ #category : #accessing }
GtRrJobProgressNotification >> jobName [
	^ self job name
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

{ #category : #callbacks }
GtRrJobProgressNotification >> spawnInspectToolFromSource: anElement [
	GtInspectorTool
		openWrappedOn: self job
		title: self job name
		from: anElement 
]

{ #category : #callbacks }
GtRrJobProgressNotification >> spawnState: aGroupState fromSource: anElement [
	GtInspectorTool
		openWrappedOn: aGroupState items
		title: aGroupState name
		from: anElement 
]

{ #category : #subscriptions }
GtRrJobProgressNotification >> subscribeToJob [
	self job
		when: GtRrTaskCompletedAnnouncement
		send: #actOnTaskCompletedFor:
		to: self
]

{ #category : #accessing }
GtRrJobProgressNotification >> summaryClass [
	"Return a class that when instantiated displays the notification summary to the user"
	^ GtRrJobNotificationSummary
]

{ #category : #accessing }
GtRrJobProgressNotification >> taskResults [
	^ taskResults
]

{ #category : #accessing }
GtRrJobProgressNotification >> unsubscribeFromJob [
	self job unsubscribe: self
]
