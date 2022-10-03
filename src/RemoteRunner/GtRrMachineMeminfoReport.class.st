Class {
	#name : #GtRrMachineMeminfoReport,
	#superclass : #Object,
	#instVars : [
		'memFree',
		'buffers',
		'cached',
		'swapTotal',
		'swapFree'
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
GtRrMachineMeminfoReport >> memFree [

	^ memFree
]

{ #category : #accessing }
GtRrMachineMeminfoReport >> memFree: anObject [

	memFree := anObject
]

{ #category : #profiling }
GtRrMachineMeminfoReport >> recordReportStatistics [
	| keys missingCount|
	
	keys := #('MemFree' 'Buffers' 'Cached' 'SwapTotal' 'SwapFree').
	missingCount := keys size.
	
	'/proc/meminfo' asFileReference readStreamDo: [ :stream |
		[ stream atEnd ] whileFalse:[ 
			| line fields currentKey keyIndex |
			line := stream nextLine.
			fields := $: split: line. 
			currentKey := fields first trimBoth.
			keyIndex := keys indexOf: currentKey.
			keyIndex > 0 ifTrue: [
				self 
					perform: currentKey uncapitalized asMutator
					with: fields second trimBoth ] ] ]
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
