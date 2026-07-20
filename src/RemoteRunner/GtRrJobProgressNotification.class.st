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
		'taskCount',
		'succeededCount',
		'erroredCount',
		'taskExecutionResults'
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

	self addTaskAnnouncement: anAnnouncement.
	self notifyNotificationDataChanged.
]

{ #category : #accessing }
GtRrJobProgressNotification >> addTaskAnnouncement: anAnnouncement [

	taskExecutionResults add: anAnnouncement taskExecutionResult.
	anAnnouncement executionData hasErrors
		ifTrue: [ erroredCount := erroredCount + 1 ]
		ifFalse: [ succeededCount := succeededCount + 1 ]
]

{ #category : #accessing }
GtRrJobProgressNotification >> constructStates [

	^ {
		(GtRrDataGroupState forNotification: self)
			name: 'All';
			itemCount: taskCount;
			itemsComputation: [ self job tasks ].
		(GtRrDataGroupState forNotification: self)
			name: 'Success';
			itemCount: succeededCount;
			itemsComputation: [ self successfulChecks ].
		(GtRrDataGroupState forNotification: self)
			name: 'Error';
			itemCount: erroredCount;
			itemsComputation: [ self erroredChecks ].
		(GtRrDataGroupState forNotification: self)
			name: 'Executing';
			itemCount: taskCount - succeededCount - erroredCount;
			itemsComputation: [ self job notExecutedExamples ]} 
]

{ #category : #accessing }
GtRrJobProgressNotification >> elementClass [
	"Return a class that when instantiated displayes the notification to user (as a widget)"
	<return: #GtNotificationEventElement>
	
	^ GtRrJobNotificationElement 
]

{ #category : #accessing }
GtRrJobProgressNotification >> erroredCount [

	^ erroredCount
]

{ #category : #'gt - extensions' }
GtRrJobProgressNotification >> gtViewNotificationStatesFor: aView [
	<gtView>
	
	^ aView columnedList
		title: 'Notification states';
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
		title: 'Task results';
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
	taskExecutionResults := OrderedCollection new.
	taskCount := job taskCount.
	succeededCount := 0.
	erroredCount := 0.
	
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

	(self job isLanguageLinkProxyObject and: [ self job isProxyObjectActive not ]) ifTrue:
		[ ^ self inform: 'Unable to inspect project object - connection closed' ].
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
		when: GtRrTaskCompletedAnnouncement, GtRrTaskFailedAnnouncement
		send: #actOnTaskCompletedFor:
		to: self
]

{ #category : #accessing }
GtRrJobProgressNotification >> succeededCount [

	^ succeededCount
]

{ #category : #accessing }
GtRrJobProgressNotification >> summaryClass [
	"Return a class that when instantiated displays the notification summary to the user"
	^ GtRrJobNotificationSummary
]

{ #category : #accessing }
GtRrJobProgressNotification >> taskCount [

	^ taskCount
]

{ #category : #accessing }
GtRrJobProgressNotification >> taskResults [
	^ taskExecutionResults collect: #taskResult
]

{ #category : #accessing }
GtRrJobProgressNotification >> unsubscribeFromJob [
	self job unsubscribe: self
]
