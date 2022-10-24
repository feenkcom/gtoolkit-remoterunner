Class {
	#name : #GtRrCheckSchedulerEntry,
	#superclass : #Object,
	#instVars : [
		'name',
		'taskClassName',
		'expectedTime'
	],
	#category : #'RemoteRunner-CheckScheduling'
}

{ #category : #accessing }
GtRrCheckSchedulerEntry >> asGtRrTask [

	^ (self class environment at: taskClassName) checkNames: { name }.
]

{ #category : #accessing }
GtRrCheckSchedulerEntry >> expectedTime [

	^ expectedTime
]

{ #category : #accessing }
GtRrCheckSchedulerEntry >> expectedTime: anObject [

	expectedTime := anObject
]

{ #category : #testing }
GtRrCheckSchedulerEntry >> hasLongerExpectedTimeThan: aGtRrCheckSchedulerEntry [

	^ expectedTime > aGtRrCheckSchedulerEntry expectedTime
]

{ #category : #testing }
GtRrCheckSchedulerEntry >> hasShorterExpectedTimeThan: aGtRrCheckSchedulerEntry [

	^ expectedTime < aGtRrCheckSchedulerEntry expectedTime
]

{ #category : #accessing }
GtRrCheckSchedulerEntry >> name [

	^ name
]

{ #category : #accessing }
GtRrCheckSchedulerEntry >> name: anObject [

	name := anObject
]

{ #category : #accessing }
GtRrCheckSchedulerEntry >> printOn: aStream [

	aStream
		<< name key asString;
		<< '>>';
		<< name value asString;
		<< ':	';
		print: expectedTime.
]

{ #category : #accessing }
GtRrCheckSchedulerEntry >> taskClassName [

	^ taskClassName
]

{ #category : #accessing }
GtRrCheckSchedulerEntry >> taskClassName: anObject [

	taskClassName := anObject
]
