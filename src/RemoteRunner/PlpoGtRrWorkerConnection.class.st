Class {
	#name : #PlpoGtRrWorkerConnection,
	#superclass : #PharoLinkProxyObject,
	#traits : 'TGtWorkerConnectionUI',
	#classTraits : 'TGtWorkerConnectionUI classTrait',
	#category : 'RemoteRunner-Runner'
}

{ #category : #accessing }
PlpoGtRrWorkerConnection class >> remoteClassName [

	^ #GtRrWorkerConnection
]

{ #category : #commands }
PlpoGtRrWorkerConnection >> commandPharoLinkServer: anInteger [

	^ self proxyPerform: #commandPharoLinkServer: 
		withPrimitiveArguments: { anInteger }
]

{ #category : #debugging }
PlpoGtRrWorkerConnection >> pharoLinkServerOnPort: anInteger [
	"Start a PharoLink server on the worker and connect"
	| settings workerApplication |

	"Start the server on the worker"
	self commandPharoLinkServer: anInteger.

	"Give the server a chance to fire up"
	1 second wait.

	"Start the client"
	settings := LanguageLinkSettings pharoDefaultSettings.
	settings
		serverProcessClass: LanguageLinkManualProcess;
		serverSocketAddress: (LanguageLinkSocketAddress
				ipOrName: self remoteAddressString
				port: anInteger).
	workerApplication := PharoLinkApplication newWith: settings.
	workerApplication start.
	^ workerApplication.
]

{ #category : #accessing }
PlpoGtRrWorkerConnection >> remoteAddress [

	^ self proxyPerform: #remoteAddress
]

{ #category : #accessing }
PlpoGtRrWorkerConnection >> remoteAddressString [

	^ self proxyPerform: #remoteAddressString
]
