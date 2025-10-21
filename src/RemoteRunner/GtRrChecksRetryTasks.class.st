Class {
	#name : #GtRrChecksRetryTasks,
	#superclass : #GtRrAbstractRetryTasks,
	#instVars : [
		'taskIdChecks'
	],
	#category : 'RemoteRunner-Announcements'
}

{ #category : #'instance creation' }
GtRrChecksRetryTasks class >> fromTasks: aCollectionOfTasks [

	^ self new taskIdChecks: (aCollectionOfTasks 
		ifNil: [ #() ]
		ifNotNil: [ :tasks |
			tasks collect: [ :task |
				task taskId -> task checkNames ] as: Array ])
]

{ #category : #serialization }
GtRrChecksRetryTasks class >> leJsonV4Name [

	^ #gtRrChecksRetryTasks
]

{ #category : #private }
GtRrChecksRetryTasks >> removeRetriedTestsFrom: aCollection [
	"Remove the tests that will be retried from the supplied collection of names"
	| testNames |

	testNames := taskIdChecks flatCollect: #value.
	^ aCollection reject: [ :each | testNames includes: each ].	
]

{ #category : #accessing }
GtRrChecksRetryTasks >> retryCount [
	"Answer the number of checks that will be retried"

	^ taskIdChecks inject: 0 into:
		[ :sum :assoc | sum + assoc value size ]
]

{ #category : #accessing }
GtRrChecksRetryTasks >> taskIdChecks [
	^ taskIdChecks
]

{ #category : #accessing }
GtRrChecksRetryTasks >> taskIdChecks: anObject [
	taskIdChecks := anObject
]
