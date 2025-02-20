Extension { #name : #PharoLinkServer }

{ #category : #'*RemoteRunner' }
PharoLinkServer >> newWorkerConnection [
	"Answer the instance to be used for RemoteRunner connections using PharoLink"

	^ GtRrWorkerConnection new
]
