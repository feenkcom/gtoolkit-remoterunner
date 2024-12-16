Class {
	#name : #PlpoGtRrJob,
	#superclass : #PharoLinkProxyObject,
	#traits : 'TPlpoGtWithAnnouncementsQueueListener',
	#classTraits : 'TPlpoGtWithAnnouncementsQueueListener classTrait',
	#instVars : [
		'taskCount',
		'originalJob'
	],
	#category : #'RemoteRunner-Jobs'
}

{ #category : #accessing }
PlpoGtRrJob class >> remoteClassName [

	^ #GtRrJob
]

{ #category : #initiailize }
PlpoGtRrJob >> actOnProxyObjectCreated [
	super actOnProxyObjectCreated.
	
	"We can start receiving announcements right after the proxy object has been fully initialized.
	The code that creates the remote job is responsible with attaching the queue before any relevant action that can trigger announcements is executed."
	self initializeAnnouncementsQueueListener.
]

{ #category : #'announcements - queue' }
PlpoGtRrJob >> announcementQueue [
	^ self proxyPerform: #announcementQueue
]

{ #category : #initiailize }
PlpoGtRrJob >> configureAnnouncementsQueueListener: aListener [
	aListener
		"timeout: self jobTimeout;"
		terminationCondition: [ self isFinished]
]

{ #category : #accessing }
PlpoGtRrJob >> endTime [
	
	^ self proxyPerformSerialized: #endTime
]

{ #category : #testing }
PlpoGtRrJob >> exceptionHandlingStrategyAllowDebugger [

	^ self proxyPerform: #exceptionHandlingStrategyAllowDebugger
]

{ #category : #testing }
PlpoGtRrJob >> hasExceptionHandlingStrategy [

	^ self proxyPerform: #hasExceptionHandlingStrategy
]

{ #category : #testing }
PlpoGtRrJob >> includesProperty: aString [

	^ originalJob
		ifNil: [ self proxyPerform: #includesProperty: withPrimitiveArguments: { aString } ]
		ifNotNil: [ originalJob includesProperty: aString ]
]

{ #category : #testing }
PlpoGtRrJob >> isChecksJob [

	^ false
]

{ #category : #testing }
PlpoGtRrJob >> isFinished [

	^ self proxyPerform: #isFinished
]

{ #category : #accessing }
PlpoGtRrJob >> job [
	"Polymorphism with {{gtClass:GtRrJobContext}}"

	^ originalJob
]

{ #category : #accessing }
PlpoGtRrJob >> jobId [
	^ self proxyPerform: #jobId
]

{ #category : #accessing }
PlpoGtRrJob >> jobName [
	
	^ self proxyPerform: #jobName
]

{ #category : #accessing }
PlpoGtRrJob >> jobTimeout [
	"Answer the receiver's timeout"

	^ self proxyPerform: #jobTimeout
]

{ #category : #accessing }
PlpoGtRrJob >> originalJob [
	^ originalJob
]

{ #category : #accessing }
PlpoGtRrJob >> originalJob: anObject [
	originalJob := anObject
]

{ #category : #accessing }
PlpoGtRrJob >> properties [

	^ self proxyPerformSerialized: #properties
]

{ #category : #'properties - accessing' }
PlpoGtRrJob >> propertyAt: aString [

	^ originalJob
		ifNil: [ self proxyPerform: #propertyAt: withPrimitiveArguments: { aString } ]
		ifNotNil: [ originalJob propertyAt: aString ]
]

{ #category : #accessing }
PlpoGtRrJob >> propertyAt: aString put: anObject [

	self proxyPerform: #propertyAt:put: withPrimitiveArguments: { aString. anObject. }.
	^ anObject
]

{ #category : #accessing }
PlpoGtRrJob >> results [
	"Answer the results from the job as an Array.
	Leave the return type as a proxy object as the size may be large."

	^ self newCommandFactory 
		setByValue;
		<< 'results asArray';
		sendAndWait.
]

{ #category : #notifications }
PlpoGtRrJob >> showProgressNotification [
	"Open a global notification showing the progress of the receiver.
	This method is explicitly added to the proxy object, so that the notification will open on the actual proxy."

	^ GtRrJobProgressNotification job: self.
]

{ #category : #accessing }
PlpoGtRrJob >> startTime [
	
	^ self proxyPerformSerialized: #startTime
]

{ #category : #accessing }
PlpoGtRrJob >> state [
	
	^ self proxyPerform: #state
]

{ #category : #accessing }
PlpoGtRrJob >> stateDescription [
	
	^ self proxyPerform: #stateDescription
]

{ #category : #accessing }
PlpoGtRrJob >> taskCount [

	^ taskCount ifNil: [ taskCount := self proxyPerform: #taskCount ].
]

{ #category : #accessing }
PlpoGtRrJob >> taskTimeout [
	
	^ self proxyPerformSerialized: #taskTimeout
]

{ #category : #accessing }
PlpoGtRrJob >> taskTimeoutSeconds: aNumber [
	
	self assert: aNumber isNumber
		description: 'Timeout must be a number'.

	^ self proxyPerform: #taskTimeoutSeconds: 
		withPrimitiveArguments: { aNumber }.
]

{ #category : #accessing }
PlpoGtRrJob >> tasks [

	^ self newCommandFactory 
		setByValue;
		<< 'self tasks asArray';
		sendAndWait.
]

{ #category : #'announcer - subscription' }
PlpoGtRrJob >> unsubscribe: anObject [
	"Unsubscribe all subscriptions of anObject from the receiver"
	
	^ self announcer unsubscribe: anObject
]

{ #category : #'announcer - subscription' }
PlpoGtRrJob >> when: anAnnouncementClass send: aSelector to: anObject [

		^ self announcer when: anAnnouncementClass send: aSelector to: anObject
]
