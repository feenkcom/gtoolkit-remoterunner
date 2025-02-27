Extension { #name : #GtRrWorkerManager }

{ #category : #'*RemoteRunner-MQ' }
GtRrWorkerManager >> forLocalStompMq [

	remoteIpAddress := 'localhost:', StampConstants defaultPort asString.
	connectionStrategyId := #stompMq.
]

{ #category : #'*RemoteRunner-MQ' }
GtRrWorkerManager >> forStompMq [

	remoteIpAddress := GtRrStompMqProcessor defaultHostName.
	self assert: remoteIpAddress isNotNil.
	connectionStrategyId := #stompMq.
]
