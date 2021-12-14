Class {
	#name : #GtRrTaskContext,
	#superclass : #Object,
	#instVars : [
		'platformContext',
		'taskContextId',
		'task',
		'workerFuture'
	],
	#category : #'RemoteRunner-Runner-State'
}

{ #category : #jsonV3 }
GtRrTaskContext class >> leJsonV4AttributeMapping [
	"Answer the collection of attribute to store keys."

	^ OrderedCollection new
		add: #taskContextId -> #taskContextId;
		add: #task -> #task;
		yourself.
]

{ #category : #accessing }
GtRrTaskContext class >> leJsonV4Name [

	^ #taskContext
]

{ #category : #accessing }
GtRrTaskContext >> connection [

	^ workerFuture connection
]

{ #category : #accessing }
GtRrTaskContext >> errorDetails: anObject [

	task errorDetails: anObject
]

{ #category : #initialization }
GtRrTaskContext >> initialize [

	super initialize.
	taskContextId := UUID new asString.
]

{ #category : #accessing }
GtRrTaskContext >> jobContext [

	^ platformContext jobContext
]

{ #category : #running }
GtRrTaskContext >> markTaskCancelled [

	task markTaskCancelled.
	platformContext markTaskCancelled: self.
]

{ #category : #running }
GtRrTaskContext >> markTaskCompleted [

	task markTaskCompleted.
	platformContext markTaskCompleted: self.
]

{ #category : #running }
GtRrTaskContext >> markTaskStarted [ 

	task markTaskStarted.
	platformContext markTaskStarted: self.
]

{ #category : #accessing }
GtRrTaskContext >> platformContext [

	^ platformContext
]

{ #category : #accessing }
GtRrTaskContext >> platformContext: anObject [

	platformContext := anObject
]

{ #category : #printing }
GtRrTaskContext >> printOn: aStream [

	task
		ifNil: [ super printOn: aStream ]
		ifNotNil: [ task printOn: aStream ]
]

{ #category : #accessing }
GtRrTaskContext >> result: anObject [

	task result: anObject
]

{ #category : #running }
GtRrTaskContext >> run [
	"Run the receiver's task"

	^ task run
]

{ #category : #accessing }
GtRrTaskContext >> task [

	^ task
]

{ #category : #accessing }
GtRrTaskContext >> task: anObject [

	task := anObject
]

{ #category : #accessing }
GtRrTaskContext >> taskContextId [
	<return: #String>

	^ taskContextId
]

{ #category : #accessing }
GtRrTaskContext >> taskContextId: anObject [

	taskContextId := anObject
]

{ #category : #accessing }
GtRrTaskContext >> taskId [

	^ task taskId
]

{ #category : #accessing }
GtRrTaskContext >> workerFuture [
	<return: #GtRrFutureWorkerTask>

	^ workerFuture
]

{ #category : #accessing }
GtRrTaskContext >> workerFuture: aGtRrFutureWorkerTask [

	workerFuture := aGtRrFutureWorkerTask.
	task workerIpAddress: workerFuture remoteAddress.
]

{ #category : #accessing }
GtRrTaskContext >> workerIpAddress: anObject [

	task workerIpAddress: anObject
]
