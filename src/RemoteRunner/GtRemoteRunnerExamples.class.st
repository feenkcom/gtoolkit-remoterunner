Class {
	#name : #GtRemoteRunnerExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRemoteRunnerExamples >> assignTasksToWorkersTaskFirst [
	"Demonstrate assigning tasks to workers, with the tasks queued before the workers connect"
	<gtExample>
	| remoteRunner workers job tasks taskCompletedCount taskFailedCount jobCompletedCount semaphore |

	jobCompletedCount := taskCompletedCount := taskFailedCount := 0.
	semaphore := GtMutualExclusionSemaphore new.
	remoteRunner := GtRemoteRunner new.
	tasks := (1 to: 5) collect: [ :i |
		GtRrExampleValueTask new
			value: i ] as: OrderedCollection.
	tasks add: (GtRrExampleValueTask new
			value: 'error1';
			setError).
	job := GtRrTasksJob new
		platforms: #(plat1 plat2);
		tasks: tasks.
	job
		when: GtRrJobCompletedAnnouncement do: 
			[ jobCompletedCount := jobCompletedCount + 1.
			semaphore signal ];
		when: GtRrTaskCompletedAnnouncement 
			do: [ taskCompletedCount := taskCompletedCount + 1 ];
		when: GtRrTaskFailedAnnouncement 
			do: [ taskFailedCount := taskFailedCount + 1 ].
	remoteRunner submitJob: job.

	workers := (1 to: 2) collect: [ :i |
		PharoLinkServerCurrentConnection 
			value: PharoLinkServerConnection new
			during:
				[ GtRrInImageWorker new
					rrPlatform: 'plat', i asString;
					remoteRunner: remoteRunner;
					start ] ].

	semaphore wait.
	self assert: job results size equals: 12.
	self assert: taskCompletedCount equals: 10.
	self assert: taskFailedCount equals: 2.
	self assert: jobCompletedCount equals: 1.

	workers do: #stop.
	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> assignTasksToWorkersWorkerFirst [
	"Demonstrate assigning tasks to workers, with the tasks queued before the workers connect"
	<gtExample>
	| remoteRunner workers job tasks taskCompletedCount taskFailedCount jobCompletedCount semaphore |

	jobCompletedCount := taskCompletedCount := taskFailedCount := 0.
	semaphore := GtMutualExclusionSemaphore new.
	remoteRunner := GtRemoteRunner new.

	workers := (1 to: 2) collect: [ :i |
		PharoLinkServerCurrentConnection 
			value: PharoLinkServerConnection new
			during:
				[ GtRrInImageWorker new
					rrPlatform: 'plat', i asString;
					remoteRunner: remoteRunner;
					start ] ].

	tasks := (1 to: 5) collect: [ :i |
		GtRrExampleValueTask new
			value: i ] as: OrderedCollection.
	tasks add: (GtRrExampleValueTask new
			value: 'error1';
			setError).
	job := GtRrTasksJob new
		platforms: #(plat1 plat2);
		tasks: tasks.
	job
		when: GtRrJobCompletedAnnouncement do: 
			[ jobCompletedCount := jobCompletedCount + 1.
			semaphore signal ];
		when: GtRrTaskCompletedAnnouncement 
			do: [ taskCompletedCount := taskCompletedCount + 1 ];
		when: GtRrTaskFailedAnnouncement 
			do: [ taskFailedCount := taskFailedCount + 1 ].
	remoteRunner submitJob: job.

	semaphore wait.
	self assert: job results size equals: 12.
	self assert: taskCompletedCount equals: 10.
	self assert: taskFailedCount equals: 2.
	self assert: jobCompletedCount equals: 1.

	workers do: #stop.
	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> getNextTaskFor [
	"Demonstrate getting the next task for a given platform from a Remote Runner"
	<gtExample>
	| job tasks taskIds remoteRunner firstTask plat1Tasks plat2Tasks |

	tasks := (1 to: 5) collect: [ :i |
		GtRrExampleValueTask new
			value: i ] as: OrderedCollection.
	taskIds := tasks collect: #taskId as: Set.
	job := GtRrTasksJob new
		platforms: #(plat1 plat2);
		tasks: tasks.
	remoteRunner := GtRemoteRunner new.
	"The remote runner has enough state to run this example without being started"
	remoteRunner startJob: job.
	self assert: remoteRunner currentlyExecutingJobs size equals: 1.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	firstTask := (remoteRunner currentlyExecutingJobs anyOne atPlatform: #plat2) pendingTasks itemArray first.

	plat1Tasks := OrderedCollection new.
	plat2Tasks := OrderedCollection new.
	plat1Tasks add: (remoteRunner getNextTaskFor: #plat1).
	plat2Tasks add: (remoteRunner getNextTaskFor: #plat2).
	plat1Tasks add: (remoteRunner getNextTaskFor: #plat1).
	plat1Tasks add: (remoteRunner getNextTaskFor: #plat1).
	plat2Tasks add: (remoteRunner getNextTaskFor: #plat2).
	plat2Tasks add: (remoteRunner getNextTaskFor: #plat2).
	plat1Tasks add: (remoteRunner getNextTaskFor: #plat1).
	plat2Tasks add: (remoteRunner getNextTaskFor: #plat2).
	plat1Tasks add: (remoteRunner getNextTaskFor: #plat1).
	plat2Tasks add: (remoteRunner getNextTaskFor: #plat2).

	self assert: plat1Tasks first task class equals: GtRrExampleValueTask.
	self assert: (plat1Tasks collect: #taskId as: Set) equals: taskIds.
	self assert: (plat2Tasks collect: #taskId as: Set) equals: taskIds.
	self assert: (remoteRunner currentlyExecutingJobs anyOne atPlatform: #plat1) pendingTasks isEmpty.
	self assert: (remoteRunner currentlyExecutingJobs anyOne atPlatform: #plat2) pendingTasks isEmpty.
]

{ #category : #examples }
GtRemoteRunnerExamples >> handleWorkerDisconnection [
	"Demonstrate the runner handling worker disconnection"
	<gtExample>
	| runner worker workerProcess job startSemaphore endSemaphore retry |

	runner := GtRemoteRunner new
		port: 7084;
		managerStartupAndShutdown: GtRrManualManagerStartupAndShutdown new;
		start.
	worker := GtRrWorker newWith: (LanguageLinkSettings pharoDefaultSettings
			serverProcessClass: LanguageLinkManualProcess;
			serverSocketAddress:
				(LanguageLinkSocketAddress from: 'localhost:7084')).
	worker start.
	workerProcess := [ worker taskPollForever ] fork.
	startSemaphore := Semaphore new.
	endSemaphore := Semaphore new.
	job := GtRrTasksJob new
		tasks: { GtRrScriptTask script: 'Semaphore new wait' }.
	job
		when: GtRrJobStartedAnnouncement
			do: [ startSemaphore signal ];
		when: GtRrJobCompletedAnnouncement
			do: [ endSemaphore signal ].

	retry := 50.
	[ retry > 0 and: [ runner availableWorkerCount = 0 ] ] whileTrue:
		[ 500 milliSeconds wait ].
	retry = 0 ifTrue:
		[ self error: 'Worker didn''t connect' ].
	self assert: runner state equals: #idle.
	self assert: runner registeredWorkerCount equals: 1.
	self assert: runner availableWorkerCount equals: 1.

	runner submitJob: job.
	startSemaphore wait.
	self assert: runner state equals: #busy.
	self assert: runner registeredWorkerCount equals: 1.
	self assert: runner availableWorkerCount equals: 0.
	self assert: job state equals: #started.

	worker stop.
	workerProcess terminate.
	endSemaphore wait.
	self assert: runner state equals: #idle.
	self assert: runner registeredWorkerCount equals: 0.
	self assert: runner availableWorkerCount equals: 0.
	self assert: job state equals: #completed.
	self assert: job hasErrors.

	runner stop.

]
