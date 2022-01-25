Class {
	#name : #GtRrCodeSyncExamples,
	#superclass : #Object,
	#category : #'RemoteRunner-Examples'
}

{ #category : #accessing }
GtRrCodeSyncExamples >> addRemoveMethod [

	<gtExample>
	| runner codeSync connectSemaphore |
	runner := GtRrScheduler new
		          "    port: 8042;"startLogging;
		          yourself.
	codeSync := runner environment codeSync.
	connectSemaphore := Semaphore new.
	[ 
	runner
		when: GtRrWorkerConnectedAnnouncement
		send: #signal
		to: connectSemaphore.
	runner start.
	"wait for both connects"
	connectSemaphore
		waitTimeoutSeconds: 20;
		waitTimeoutSeconds: 2.
	"add/remove method changes should be propagated to workers"
	self assert: (self hasMethodIn: runner) not.
	self class compile: 'blub ^ 1'.
	2 seconds wait.
	self assert: (self hasMethodIn: runner).
	self class removeSelector: #blub.
	2 seconds wait.
	self assert: (self hasMethodIn: runner) not.
	"stopping sync should no longer propagate changes"
	codeSync stop.
	self class compile: 'blub ^ 1'.
	2 seconds wait.
	self assert: (self hasMethodIn: runner) not ] ensure: [ 
		self class removeSelector: #blub.
		runner stop ].
	^ runner
]

{ #category : #accessing }
GtRrCodeSyncExamples >> hasMethodIn: aRunner [

	| task |
	task := GtRrScriptTask script:
		        self class name , ' includesSelector: #blub'.
	^ (aRunner future: task timeout: 2 seconds) synchronizeTimeout:
		  5 seconds
]

{ #category : #accessing }
GtRrCodeSyncExamples >> wait: aDuration for: anAnnouncement in: anAnnouncer [

	| semaphore |
	semaphore := Semaphore new.
	anAnnouncer when: anAnnouncement send: #signal to: semaphore.
	semaphore wait: aDuration onCompletion: [ "noop" ] onTimeout: [ 
		self error: ('wait {1} for {2} in {3} timed out' format: { 
					 aDuration.
					 anAnnouncement.
					 anAnnouncer }) ]
]
