Class {
	#name : #GtRrWorkerManagerExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrWorkerManagerExamples >> stopOnSessionChange [
	"Ensure that the worker manager stops the watchdog when the session changes"

	<gtExample>
	<return: #GtRrWorkerManager>
	| workerManager semaphore process |
	workerManager := GtRrWorkerManager new.
	semaphore := Semaphore new.
	process := [ semaphore wait ] fork.
	workerManager processes add: process.
	workerManager startWatchdog.
	self assert: workerManager isRunning.
	workerManager instVarNamed: #currentSession put: Object new.
	workerManager signalWatchdog.
	self waitForManagerWatchdog: workerManager.
	self deny: workerManager isRunning.
	self assert: workerManager state identicalTo: #sessionIdChanged.
	semaphore signal.
	^ workerManager
]

{ #category : #'private - helpers' }
GtRrWorkerManagerExamples >> waitForManagerWatchdog: workerManager [ 
	| count |

	count := 0.
	[ count < 300 and: [ workerManager isRunning ] ] whileTrue:
		[ 100 milliseconds wait.
		count := count + 1 ].
]
