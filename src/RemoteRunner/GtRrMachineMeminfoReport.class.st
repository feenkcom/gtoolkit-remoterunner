Class {
	#name : #GtRrMachineMeminfoReport,
	#superclass : #Object,
	#instVars : [
		'memFree',
		'buffers',
		'cached',
		'swapTotal',
		'swapFree',
		'memAvailable',
		'memTotal'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #serialization }
GtRrMachineMeminfoReport class >> leJsonV4Name [
	^ #gtRrMachineMeminfoReport
]

{ #category : #accessing }
GtRrMachineMeminfoReport >> buffers [

	^ buffers
]

{ #category : #accessing }
GtRrMachineMeminfoReport >> buffers: anObject [

	buffers := anObject
]

{ #category : #accessing }
GtRrMachineMeminfoReport >> cached [

	^ cached
]

{ #category : #accessing }
GtRrMachineMeminfoReport >> cached: anObject [

	cached := anObject
]

{ #category : #accessing }
GtRrMachineMeminfoReport >> memAvailable [

	^ memAvailable
]

{ #category : #accessing }
GtRrMachineMeminfoReport >> memAvailable: anObject [

	memAvailable := anObject
]

{ #category : #accessing }
GtRrMachineMeminfoReport >> memFree [

	^ memFree
]

{ #category : #accessing }
GtRrMachineMeminfoReport >> memFree: anObject [

	memFree := anObject
]

{ #category : #accessing }
GtRrMachineMeminfoReport >> memTotal [

	^ memTotal
]

{ #category : #accessing }
GtRrMachineMeminfoReport >> memTotal: anObject [

	memTotal := anObject
]

{ #category : #profiling }
GtRrMachineMeminfoReport >> recordReportStatistics [
	| keys missingCount|
	
	keys := #('MemTotal' 'MemAvailable' 'MemFree' "'Buffers' 'Cached' 'SwapTotal' 'SwapFree'").
	missingCount := keys size.
	
	'/proc/meminfo' asFileReference readStreamDo: [ :stream |
		[ stream atEnd or: [missingCount = 0 ] ] whileFalse:[ 
			| line fields currentKey keyIndex |
			line := stream nextLine.
			fields := $: split: line. 
			currentKey := fields first trimBoth.
			keyIndex := keys indexOf: currentKey.
			keyIndex > 0 ifTrue: [
				missingCount := missingCount - 1.
				self 
					perform: currentKey uncapitalized asSymbol asMutator
					with: fields second trimBoth asNumber * 1024 ] ] ]
]

{ #category : #accessing }
GtRrMachineMeminfoReport >> swapFree [

	^ swapFree
]

{ #category : #accessing }
GtRrMachineMeminfoReport >> swapFree: anObject [

	swapFree := anObject
]

{ #category : #accessing }
GtRrMachineMeminfoReport >> swapTotal [

	^ swapTotal
]

{ #category : #accessing }
GtRrMachineMeminfoReport >> swapTotal: anObject [

	swapTotal := anObject
]
