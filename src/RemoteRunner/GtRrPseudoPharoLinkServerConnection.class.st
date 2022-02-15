"
GtRrPseudoPharoLinkServerConnection provides enough functionality for the {{gtClass:GtRrInImageWorker}} to operate.  See examples using {{gtClass:GtRrInImageWorker}}.
"
Class {
	#name : #GtRrPseudoPharoLinkServerConnection,
	#superclass : #Object,
	#traits : 'TGtAnnouncer',
	#classTraits : 'TGtAnnouncer classTrait',
	#instVars : [
		'announcer'
	],
	#category : #'RemoteRunner-Examples'
}

{ #category : #announcer }
GtRrPseudoPharoLinkServerConnection >> announcer [
	<return: #Announcer>

	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #accessing }
GtRrPseudoPharoLinkServerConnection >> remoteAddress [

	^ #[127 0 0 1]
]

{ #category : #initialization }
GtRrPseudoPharoLinkServerConnection >> setCloseOnExec: aBoolean [

]
