Extension { #name : #TKTRunningTaskState }

{ #category : #'*RemoteRunner' }
TKTRunningTaskState >> cancelTaskExecution: aTaskExecution reason: aReason [
	| cancelState activeContext timeoutContext taskProcess |

	taskProcess := aTaskExecution executionProcess.
	"#isSuspended may be too broad, ideally we should have something like #isBeingDebugged.
	The suspended check prevents errors when terminating a task that is debugged or suspended due to an exception.
	See https://github.com/feenkcom/gtoolkit/issues/1823"
	taskProcess isSuspended ifTrue: [ ^ self ].

	cancelState := TKTCancelledTaskState reason: aReason.

	taskProcess suspend.
	activeContext := taskProcess suspendedContext.
	timeoutContext := [ cancelState signalCancelledException ] asContext.
	timeoutContext privSender: activeContext.
	taskProcess suspendedContext: timeoutContext.
	aTaskExecution setCancelStateWithReason: aReason.
	taskProcess priority: (Processor lowIOPriority min: taskProcess priority + 5).
	taskProcess resume.
]
