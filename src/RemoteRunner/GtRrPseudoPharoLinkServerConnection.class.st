"
GtRrPseudoPharoLinkServerConnection provides enough functionality for the {{gtClass:GtRrInImageWorker}} to operate.  See examples using {{gtClass:GtRrInImageWorker}}.
"
Class {
	#name : #GtRrPseudoPharoLinkServerConnection,
	#superclass : #Object,
	#traits : 'TGtAnnouncer',
	#classTraits : 'TGtAnnouncer classTrait',
	#instVars : [
		'announcer',
		'worker'
	],
	#category : #'RemoteRunner-Examples'
}

{ #category : #announcer }
GtRrPseudoPharoLinkServerConnection >> announcer [
	<return: #Announcer>

	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #initialization }
GtRrPseudoPharoLinkServerConnection >> closeOnExec: aBoolean [

]

{ #category : #testing }
GtRrPseudoPharoLinkServerConnection >> isConnected [
	"GtRrPseudoPharoLinkServerConnection doesn't really know if it is running or not, answer true"

	^ true
]

{ #category : #accessing }
GtRrPseudoPharoLinkServerConnection >> remoteAddress [

	^ #[127 0 0 1]
]

{ #category : #accessing }
GtRrPseudoPharoLinkServerConnection >> remoteAddressString [

	^ GtRemoteRunner printIpAddress: self remoteAddress
]

{ #category : #'start-stop' }
GtRrPseudoPharoLinkServerConnection >> start [
	"Nothing to do"
]

{ #category : #'start-stop' }
GtRrPseudoPharoLinkServerConnection >> stop [

	worker ifNotNil: [ worker stop ]
]

{ #category : #accessing }
GtRrPseudoPharoLinkServerConnection >> worker [
	^ worker
]

{ #category : #accessing }
GtRrPseudoPharoLinkServerConnection >> worker: anObject [
	worker := anObject
]
