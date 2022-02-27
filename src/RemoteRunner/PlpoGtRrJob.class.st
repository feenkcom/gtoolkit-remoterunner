Class {
	#name : #PlpoGtRrJob,
	#superclass : #PharoLinkProxyObject,
	#category : #'RemoteRunner-Jobs'
}

{ #category : #accessing }
PlpoGtRrJob class >> remoteClassName [

	^ #GtRrJob
]

{ #category : #accessing }
PlpoGtRrJob >> isFinished [

	^ self proxyPerform: #isFinished
]

{ #category : #accessing }
PlpoGtRrJob >> results [
	"Answer the results from the job as an Array.
	Leave the return type as a proxy object as the size may be large."

	^ self newCommandFactory 
		<< 'results asArray';
		sendAndWait.
]
