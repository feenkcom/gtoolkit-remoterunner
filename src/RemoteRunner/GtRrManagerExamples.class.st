Class {
	#name : #GtRrManagerExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : 'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrManagerExamples >> decreasePoolSize [
	"Demonstrate decreasing the worker pool size"
	<gtExample>
	<noTest>
	| runner workerCount semaphore |

	workerCount := 0.
	semaphore := Semaphore new.
	runner := GtRemoteRunner new
		startLogging;
		port: 7082.
	runner managerStartupAndShutdown poolSize: 2.
	runner
		when: GtRrWorkerReplacedAnnouncement
			do: [ :ann | semaphore signal ]
			for: self;
		when: GtRrWorkerRegisteredAnnouncement
			do: [ :ann | 
				workerCount := workerCount + 1.
				semaphore signal ]
			for: self;
		when: GtRrWorkerUnregisteredAnnouncement 
			do: [ :ann | 
				workerCount := workerCount - 1.
				semaphore signal ]
			for: self.

	"auto-restart should be disabled in the manager"
	self deny: runner managerStartupAndShutdown autoRestart.

	[ runner start.
	2 timesRepeat: [ semaphore
		waitTimeoutMilliseconds: 10 seconds asMilliSeconds
		onCompletion: [  ]
		onTimeout: [ self error: 'Didn''t get initial workers registered' ] ].

	self assert: workerCount equals: 2.
	self assert: runner managerStartupAndShutdown processCount equals: 2.

	runner managerStartupAndShutdown poolSize: 1.
	semaphore
		waitTimeoutMilliseconds: 10 seconds asMilliSeconds
		onCompletion: [  ]
		onTimeout: [ self error: 'Didn''t get worker unregistered' ].

	runner managerStartupAndShutdown signalWatchdog.
	semaphore
		waitTimeoutMilliseconds: 10 seconds asMilliSeconds
		onCompletion: [  ]
		onTimeout: [ self error: 'Didn''t get worker replaced' ].

	self assert: workerCount equals: 1.
	self assert: runner managerStartupAndShutdown processCount equals: 1.
	] ensure: [ runner stop ].

	^ runner

]

{ #category : #examples }
GtRrManagerExamples >> increasePoolSize [
	"Demonstrate increasing the worker pool size"
	<gtExample>
	<noTest>
	| runner workerCount semaphore |

	workerCount := 0.
	semaphore := Semaphore new.
	runner := GtRemoteRunner new
		startLogging;
		port: 7081.
	runner managerStartupAndShutdown poolSize: 1.
	runner
		when: GtRrWorkerRegisteredAnnouncement
			do: [ :ann | 
				workerCount := workerCount + 1.
				semaphore signal ]
			for: self;
		when: GtRrWorkerUnregisteredAnnouncement 
			do: [ :ann | 
				workerCount := workerCount - 1.
				semaphore signal ]
			for: self.

	[ runner start.

	semaphore
		waitTimeoutMilliseconds: 10 seconds asMilliSeconds
		onCompletion: [  ]
		onTimeout: [ self error: 'Didn''t get initial worker registered' ].

	self assert: workerCount equals: 1.
	self assert: runner managerStartupAndShutdown processCount equals: 1.

	runner managerStartupAndShutdown poolSize: 2.
	semaphore
		waitTimeoutMilliseconds: 10 seconds asMilliSeconds
		onCompletion: [  ]
		onTimeout: [ self error: 'Didn''t get additional worker registered' ].
	self assert: workerCount equals: 2.
	self assert: runner managerStartupAndShutdown processCount equals: 2.
	] ensure: [ runner stop ].

	^ runner

]
