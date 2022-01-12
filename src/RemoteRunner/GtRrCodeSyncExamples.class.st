Class {
	#name : #GtRrCodeSyncExamples,
	#superclass : #Object,
	#category : #'RemoteRunner-Examples'
}

{ #category : #accessing }
GtRrCodeSyncExamples >> addRemoveMethod [

	<gtExample>
	| runner codeSync |
	runner := GtRemoteRunner new
		          port: 8042;
		          startLogging;
		          yourself.
	codeSync := runner managerStartupAndShutdown codeSync.
	[ 
	runner start.
	self
		wait: 10 seconds
		for: GtRrWorkerRegisteredAnnouncement
		in: runner.
	"add/remove method changes should be propagated to workers"
	self assert: (self hasMethodIn: runner) not.
	self class compile: 'blub ^ 1'.
	self assert: (self hasMethodIn: runner).
	self class removeSelector: #blub.
	self assert: (self hasMethodIn: runner) not.
	"stopping sync should no longer propagate changes"
	codeSync stop.
	self class compile: 'blub ^ 1'.
	self assert: (self hasMethodIn: runner) not ] ensure: [ 
		self class removeSelector: #blub.
		runner stop ].
	^ runner
]

{ #category : #accessing }
GtRrCodeSyncExamples >> hasMethodIn: aRunner [

	| job |
	job := GtRrTasksJob tasks:
		       { (GtRrScriptTask script:
			        self class name , ' includesSelector: #blub') }.
	aRunner submitJob: job.
	self wait: 5 seconds for: GtRrJobCompletedAnnouncement in: job.
	^ job tasks first result
]

{ #category : #accessing }
GtRrCodeSyncExamples >> wait: aDuration for: anAnnouncement in: anAnnouncer [

	| semaphore |
	semaphore := Semaphore new.
	anAnnouncer
		when: anAnnouncement
		doOnce: [ semaphore signal ]
		for: self.
	semaphore wait: aDuration onCompletion: [ "noop" ] onTimeout: [ 
		self error: ('wait {1} for {2} in {3} timed out' format: { 
					 aDuration.
					 anAnnouncement.
					 anAnnouncer }) ]
]
