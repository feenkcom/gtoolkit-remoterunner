Extension { #name : #GtRrWorkerManager }

{ #category : #'*RemoteRunner-MQ' }
GtRrWorkerManager >> forLocalStompMq [

	remoteIpAddress := 'localhost:', StampConstants defaultPort asString.
	connectionStrategyId := #stompMq.
]
