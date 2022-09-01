Class {
	#name : #GtRrJobNotificationExamples,
	#superclass : #Object,
	#traits : 'TGtRrExampleHelp',
	#classTraits : 'TGtRrExampleHelp classTrait',
	#instVars : [
		'theRunner'
	],
	#category : #'RemoteRunner-Examples'
}

{ #category : #accessing }
GtRrJobNotificationExamples >> completedNotificationForExamplesClassJob [
	<gtExample>
	| jobSemaphore remoteRunner job notification |
	
	jobSemaphore := GtMutualExclusionSemaphore new.
	
	remoteRunner := self simpleInImageStartedRunner.
	job := GtRrJobExamples new testJobExamplesClassNames.
	job 
		when: GtRrJobCompletedAnnouncement do: [ jobSemaphore signal ].
			
	notification := GtRrExamplesProgressNotification new job: job.
		
	remoteRunner submitJob: job.
	self waitOn: jobSemaphore for: 10 description: 'Job didn''t complete in time'.
	
	self assert: notification totalChecksCount equals: 3.
	self assert: notification successfulChecksCount equals: 1.
	self assert: notification skippedChecksCount equals: 02.
	self assert: notification failedChecksCount equals: 0.
	self assert: notification erroredChecksCount equals: 0.
	
	self assert: notification taskResults size equals: 1.
	
	^ notification
]

{ #category : #accessing }
GtRrJobNotificationExamples >> notStartedNotificationForExamplesClassJob [
	<gtExample>
	| job notification |
	job := GtRrJobExamples new testJobExamplesClassNames.
	notification := GtRrExamplesProgressNotification new 
		job: job.
	
	self assert: notification totalChecksCount equals: 3.
	self assert: notification successfulChecksCount equals: 0.
	self assert: notification skippedChecksCount equals: 0.
	self assert: notification failedChecksCount equals: 0.
	self assert: notification erroredChecksCount equals: 0.
	
	self assert: notification taskResults size equals: 0.
	
	^ notification
]

{ #category : #'examples - setup' }
GtRrJobNotificationExamples >> simpleInImageRunner [
	<gtExample>
	| newRunner |
	
	newRunner := GtRemoteRunner new.
	newRunner managerStartupAndShutdown: GtRrManualManagerStartupAndShutdown new.
	
	^ newRunner
]

{ #category : #'examples - setup' }
GtRrJobNotificationExamples >> simpleInImageStartedRunner [
	"Demonstrate executing a simple task"
	<gtExample>
	<after: #stopRunner>
	
	^ theRunner ifNil: [ 
		| runner |
	
		runner := self simpleInImageRunner.
		runner managerStartupAndShutdown startInImageWorker.
		runner start.
		
		theRunner := runner ]
]

{ #category : #cleanup }
GtRrJobNotificationExamples >> stopRunner [
	theRunner ifNotNil: [ :aRunner |
		aRunner stop.
		theRunner := nil ]
]
